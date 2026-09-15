# Issuing a wildcard Let's Encrypt cert via Certbot + Cloudflare DNS-01

## 1 .Native (non-Docker) approach — cleaner since certs already live on the host
1. `sudo apt install certbot python3-certbot-dns-cloudflare`
2. Reuse the existing `cloudflare.ini`.
3. Request cert with explicit paths so Nginx's existing volume mount keeps working:
   ```bash
   sudo certbot certonly --dns-cloudflare \
     --dns-cloudflare-credentials /apps/runtime/certbot/cloudflare.ini \
     -d juissy.net -d '*.juissy.net' \
     --config-dir /apps/runtime/certbot/conf \
     --work-dir /apps/runtime/certbot/work \
     --logs-dir /apps/runtime/certbot/logs \
     --deploy-hook "docker exec nginx nginx -s reload"
   ```
4. Apt installs a `certbot.timer` systemd timer automatically — runs `certbot renew` twice daily, only renews within 30 days of expiry. Check with:
   ```bash
   systemctl list-timers | grep certbot
   ```
5. The `--deploy-hook` reloads the Dockerized Nginx automatically on renewal (saved into the renewal config for future automatic runs too).
6. Test the whole chain without waiting 90 days:
   ```bash
   sudo certbot renew --dry-run \
     --config-dir /apps/runtime/certbot/conf \
     --work-dir /apps/runtime/certbot/work \
     --logs-dir /apps/runtime/certbot/logs
   ```
7. If cert listings look inconsistent after switching from Docker-issued to native Certbot, run `certbot delete --cert-name <name>` and reissue clean rather than mixing histories.

---

## 2. Updating Nginx site confs to use the new cert

Nginx container already mounts `/apps/runtime/certbot/conf` → `/etc/letsencrypt` (no compose changes needed).

In each site conf (`photos.juissy.net`, `video.juissy.net`, future ones), replace:
```nginx
ssl_certificate /etc/nginx/certs/origin.pem;
ssl_certificate_key /etc/nginx/certs/origin.key;
```
with:
```nginx
ssl_certificate /etc/letsencrypt/live/juissy.net/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/juissy.net/privkey.pem;
```

Then reload:
```bash
docker exec nginx nginx -t
docker exec nginx nginx -s reload
```
