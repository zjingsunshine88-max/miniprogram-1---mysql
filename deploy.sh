#!/bin/bash

# 生产环境部署脚本
echo "🚀 开始部署刷题小程序系统到生产环境..."

# 设置变量
PROJECT_ROOT=$(pwd)
BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
SERVICE_DIR="/var/www/question-bank"

# 创建备份目录
echo "📁 创建备份目录..."
sudo mkdir -p $BACKUP_DIR

# 备份现有服务（如果存在）
if [ -d "$SERVICE_DIR" ]; then
    echo "💾 备份现有服务..."
    sudo cp -r $SERVICE_DIR $BACKUP_DIR/
fi

# 创建服务目录
echo "📂 创建服务目录..."
sudo mkdir -p $SERVICE_DIR

# 1. 构建后台管理系统
echo "🔨 构建后台管理系统..."
cd $PROJECT_ROOT/admin
npm install
npm run build

# 复制构建文件到服务目录
sudo cp -r dist/* $SERVICE_DIR/admin/

# 2. 构建API服务
echo "🔨 准备API服务..."
cd $PROJECT_ROOT/server

# 安装生产依赖
npm install --production

# 创建日志目录
sudo mkdir -p $SERVICE_DIR/logs

# 复制API服务文件
sudo cp -r . $SERVICE_DIR/api/

# 3. 复制小程序文件
echo "📱 复制小程序文件..."
sudo cp -r $PROJECT_ROOT/miniprogram $SERVICE_DIR/

# 4. 设置权限
echo "🔐 设置文件权限..."
sudo chown -R www-data:www-data $SERVICE_DIR
sudo chmod -R 755 $SERVICE_DIR
sudo chmod -R 777 $SERVICE_DIR/logs
sudo chmod -R 777 $SERVICE_DIR/api/public/uploads

# 5. 安装PM2（如果未安装）
if ! command -v pm2 &> /dev/null; then
    echo "📦 安装PM2..."
    sudo npm install -g pm2
fi

# 6. 启动API服务
echo "🚀 启动API服务..."
cd $SERVICE_DIR/api
sudo pm2 delete question-bank-api 2>/dev/null || true
sudo pm2 start ecosystem.config.js --env production
sudo pm2 save
sudo pm2 startup

# 7. 配置Nginx（如果存在）
if command -v nginx &> /dev/null; then
    echo "🌐 配置Nginx..."
    
    # 创建Nginx配置
    sudo tee /etc/nginx/sites-available/question-bank << EOF
server {
    listen 80;
    server_name your-domain.com;
    
    # 后台管理系统
    location /admin {
        alias $SERVICE_DIR/admin;
        try_files \$uri \$uri/ /admin/index.html;
        
        # 静态资源缓存
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API服务
    location /api {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # 健康检查
    location /health {
        proxy_pass http://localhost:3002;
    }
}
EOF
    
    # 启用站点
    sudo ln -sf /etc/nginx/sites-available/question-bank /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx
fi

# 8. 配置SSL证书（可选）
read -p "🔒 是否配置SSL证书？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v certbot &> /dev/null; then
        sudo certbot --nginx -d your-domain.com
    else
        echo "请先安装certbot: sudo apt install certbot python3-certbot-nginx"
    fi
fi

# 9. 初始化数据库（如果需要）
read -p "🗄️ 是否需要初始化数据库？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd $SERVICE_DIR/api
    node scripts/init-db.js
    node scripts/init-admin.js
fi

echo "✅ 部署完成！"
echo "📊 服务状态："
sudo pm2 status

echo "🌐 访问地址："
echo "  后台管理: http://your-domain.com/admin"
echo "  API服务: http://your-domain.com/api"
echo "  健康检查: http://your-domain.com/health"

echo "📝 部署日志已保存到: $BACKUP_DIR"
