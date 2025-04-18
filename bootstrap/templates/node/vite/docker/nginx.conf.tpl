server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # Set the root directory for static files
    root /usr/share/nginx/html;

    # Default file to serve
    index index.html index.htm;

    # Serve static files directly
    location / {
        # Try serving file directly, then directory, then fallback to index.html for SPA routing
        try_files $uri $uri/ /index.html;
    }

    # Optional: Add caching headers for static assets
    location ~* \.(?:css|js|jpg|jpeg|gif|png|ico|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public";
    }

    # Optional: Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/xml+rss application/atom+xml image/svg+xml;

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
} 