# Step 1: Install Immich‑Go on the server
	1. Download the latest release (replace vX.Y.Z with the newest tag from Immich‑Go releases):
	wget https://github.com/simulot/immich-go/releases/download/v0.32.0/immich-go_Linux_x86_64.tar.gz
	
	tar -xvzf immich-go_Linux_x86_64.tar.gz
	
	chmod +x immich-go
	
	sudo mv immich-go /usr/local/bin/
	
	
# 2. Setup login and other settings in GUI.

# 3. Import Data

## immich-go
• You should see the CLI options.
🔑 Step 2: Prepare Immich API key
	• In the Immich web UI → Account Settings → API Keys → Create new key.
	• Copy the key (you’ll use it in the command).
		○ DU6vdGBZ4yXrZmOR3afyJcDNWtpyNjLbhgsFuoKZN4I

📂 Step 3: Run import from server

```bash
immich-go upload from-google-photos -s https://photos.juissy.net --skip-verify-ssl -k DU6vdGBZ4yXrZmOR3afyJcDNWtpyNjLbhgsFuoKZN4I --takeout-tag /data/backups/google-takeout/*.zip
  
```
	• -server=http://localhost:3001 → points to Immich running locally on the server.
	• -key=YOUR_API_KEY → replace with the key you generated.
	• upload /data/immich/zips/*.zip → processes all zips in that folder.
    • Assuming your Takeout zips are already in /data/backup/google-taekout/

IMPORT FROM Google Takeout Zips
immich-go upload from-google-photos /data/photos.tar --api-key y2uGRwvHrNFeHVXT6AaZ0L5wmWfoc74zC0ydkNCGo --server http://127.0.0.1:2283

IMPORT FROM FOLDER
immich-go upload from-folder /data/immich/zips --api-key y2uGRwvHrNFeHVXT6AaZ0L5wmWfoc74zC0ydkNCGo --server http://127.0.0.1:2283

⚙️ Options you may want
	• -skip-duplicates → ensures existing files aren’t re‑uploaded.
	• -album "Google Takeout" → puts imports into a specific album.
	• Example:
immich-go -server=http://localhost:3001 \ -key=YOUR_API_KEY \ -skip-duplicates \ -album "Google Takeout" \ upload /data/immich/zips/*.zip 

✅ What happens
	• Immich‑Go reads each zip, including the JSON metadata.
	• Uploads photos/videos directly via Immich’s API.
	• Preserves albums, favorites, and dates correctly (fixing the “10 years in the future” issue).
	• Skips duplicates if you enable that flag.
