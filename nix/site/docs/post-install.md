# Post-Installation Steps

1. Access Zoraxy, the main reverse proxy, at:  
   `http://<ip>:8000/`  
2. Configure the reverse proxy:  
   - Since the containers share the same network, use the format `<containerName>:<containerPort>` to forward requests.  
3. Repeat the configuration for all deployed containers:  
   - **Zoraxy**, **Glance**, **Vaultwarden**, **Paperless-NGX**, **SiYuan**, **NextCloud**, and **Actual-Budget**.  
