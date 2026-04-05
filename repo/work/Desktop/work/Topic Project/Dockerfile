# Use lightweight nginx image
FROM nginx:alpine

# Copy nginx configuration
COPY config/nginx.conf /etc/nginx/conf.d/default.conf

# Copy web files
COPY web/ /usr/share/nginx/html/web/

# Copy cropped questions (images)
COPY data/output/cropped_questions/ /usr/share/nginx/html/cropped_questions/

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
