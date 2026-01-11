# Project Documentation Generator Agent

## Purpose
Generate comprehensive project-level documentation including README, user guides, deployment instructions, and project overview documents.

## When to Invoke
- Creating initial project documentation
- Updating README after major changes
- Generating user guides
- Creating deployment documentation
- Documenting project setup and configuration
- Writing contributing guidelines

## Documentation Types

### 1. README.md

**Sections to Include:**
```markdown
# Project Name

Brief 1-2 sentence description of what the project does.

## Features

- Feature 1 with brief description
- Feature 2 with brief description
- Feature 3 with brief description

## Tech Stack

### Backend
- Node.js v18+
- Express.js 4.x
- PostgreSQL / MongoDB
- Jest for testing

### Frontend
- React 18+
- Material-UI 5.x
- React Router 6.x
- Vite

### Development Tools
- ESLint
- Prettier
- Git hooks (Husky)

## Prerequisites

- Node.js 18+ and npm 9+
- PostgreSQL 14+ / MongoDB 6+
- Git

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd project-name

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your configuration
nano .env

# Run database migrations
npm run migrate

# Start development server
npm run dev
```

## Environment Variables

Create a `.env` file in the root directory:

```env
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Authentication
JWT_SECRET=your-secret-key
JWT_EXPIRE=7d

# External Services
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASS=your-password
```

## Development

```bash
# Start development server with hot reload
npm run dev

# Run backend only
npm run dev:server

# Run frontend only
npm run dev:client

# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Lint code
npm run lint

# Format code
npm run format
```

## Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage report
npm run test:coverage

# Run specific test file
npm test -- path/to/test.js

# Run end-to-end tests
npm run test:e2e
```

## Building for Production

```bash
# Build frontend and backend
npm run build

# Start production server
npm start
```

## Deployment

### Docker

```bash
# Build Docker image
docker build -t project-name .

# Run container
docker run -p 3000:3000 --env-file .env project-name
```

### Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Manual Deployment

1. Ensure Node.js 18+ is installed
2. Clone repository
3. Install dependencies: `npm ci --production`
4. Set environment variables
5. Build: `npm run build`
6. Start: `npm start`

## Project Structure

```
project-name/
├── src/
│   ├── server/           # Backend code
│   │   ├── routes/       # API routes
│   │   ├── controllers/  # Route controllers
│   │   ├── services/     # Business logic
│   │   ├── models/       # Database models
│   │   ├── middleware/   # Express middleware
│   │   └── utils/        # Utility functions
│   └── client/           # Frontend code
│       ├── components/   # React components
│       ├── pages/        # Page components
│       ├── hooks/        # Custom hooks
│       ├── utils/        # Utility functions
│       └── App.jsx       # Main app component
├── tests/                # Test files
│   ├── unit/            # Unit tests
│   ├── integration/     # Integration tests
│   └── e2e/             # End-to-end tests
├── docs/                 # Documentation
├── public/               # Static files
├── .env.example          # Example environment variables
├── package.json          # Dependencies and scripts
└── README.md            # This file
```

## API Documentation

See [API Documentation](docs/API.md) for detailed API endpoint documentation.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Write tests for new features
- Follow ESLint rules
- Add JSDoc comments to functions
- Maintain test coverage above 60%
- Update documentation for significant changes

## License

MIT License - see LICENSE file for details

## Support

- Documentation: [docs/](docs/)
- Issues: [GitHub Issues](https://github.com/user/repo/issues)
- Email: support@example.com

## Acknowledgments

- [List contributors]
- [List third-party libraries with thanks]
```

### 2. DEPLOYMENT.md

```markdown
# Deployment Guide

## Overview

This guide covers deploying the application to various environments.

## Prerequisites

- Access to hosting platform
- Domain name (optional)
- SSL certificate (for HTTPS)
- Database instance
- Environment variables configured

## Environment Setup

### Production Environment Variables

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=<production-database-url>
JWT_SECRET=<strong-random-secret>
CORS_ORIGIN=https://yourdomain.com
REDIS_URL=<redis-connection-url>
```

### Security Checklist

- [ ] Change default secrets and passwords
- [ ] Enable HTTPS/SSL
- [ ] Configure CORS for production domain
- [ ] Set secure session cookies (httpOnly, secure)
- [ ] Enable rate limiting
- [ ] Set up monitoring and alerts
- [ ] Configure backup strategy
- [ ] Review and minimize exposed ports
- [ ] Enable database encryption at rest
- [ ] Set up log rotation

## Deployment Options

### Option 1: Docker + Docker Compose

#### Dockerfile
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
EXPOSE 3000
CMD ["npm", "start"]
```

#### docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/dbname
    depends_on:
      - db
      - redis

  db:
    image: postgres:14-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=dbname

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Option 2: Platform as a Service (Heroku, Railway, Render)

#### Deploy to Heroku
```bash
# Login
heroku login

# Create app
heroku create app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your-secret

# Deploy
git push heroku main

# Run migrations
heroku run npm run migrate

# Open app
heroku open
```

### Option 3: VPS (DigitalOcean, AWS EC2, Linode)

#### Server Setup
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Nginx
sudo apt install -y nginx

# Install PM2
sudo npm install -g pm2

# Setup firewall
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

#### Application Deployment
```bash
# Clone repository
git clone <repo-url> /var/www/app
cd /var/www/app

# Install dependencies
npm ci --production

# Build
npm run build

# Start with PM2
pm2 start npm --name "app" -- start
pm2 save
pm2 startup
```

#### Nginx Configuration
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### SSL with Let's Encrypt
```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal (runs twice daily)
sudo systemctl enable certbot.timer
```

## Database Management

### Migrations
```bash
# Run migrations
npm run migrate

# Rollback last migration
npm run migrate:rollback

# Create new migration
npm run migrate:create migration-name
```

### Backups
```bash
# PostgreSQL backup
pg_dump -U username dbname > backup.sql

# Restore
psql -U username dbname < backup.sql

# Automated daily backups (crontab)
0 2 * * * pg_dump -U username dbname > /backups/db_$(date +\%Y\%m\%d).sql
```

## Monitoring

### PM2 Monitoring
```bash
# View processes
pm2 list

# View logs
pm2 logs app

# Monitor resources
pm2 monit
```

### Application Monitoring
- Set up logging (Winston, Pino)
- Configure error tracking (Sentry, Rollbar)
- Set up uptime monitoring (UptimeRobot, Pingdom)
- Monitor performance (New Relic, DataDog)

## Troubleshooting

### Common Issues

**Application won't start**
- Check environment variables
- Verify database connection
- Check logs: `pm2 logs app`
- Verify port is not in use

**Database connection errors**
- Verify DATABASE_URL
- Check database is running
- Verify firewall rules
- Check database credentials

**502 Bad Gateway (Nginx)**
- Check app is running: `pm2 status`
- Verify proxy_pass port matches app port
- Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`

## Rollback Procedure

```bash
# Using PM2
pm2 stop app
git checkout previous-commit
npm ci --production
npm run build
pm2 restart app

# Using Docker
docker pull previous-image-tag
docker-compose up -d
```

## Performance Optimization

- Enable Gzip compression in Nginx
- Set up CDN for static assets
- Enable Redis caching
- Optimize database queries and indexes
- Implement database connection pooling
- Use PM2 cluster mode for multiple instances
```

### 3. SETUP.md

```markdown
# Development Setup Guide

## Initial Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd project-name
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` with your local configuration:
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://localhost:5432/myapp_dev
JWT_SECRET=dev-secret-change-in-production
```

### 4. Database Setup

#### PostgreSQL
```bash
# Create database
createdb myapp_dev

# Run migrations
npm run migrate

# Seed database (optional)
npm run seed
```

#### MongoDB
```bash
# Start MongoDB
mongod --dbpath /path/to/data

# No migrations needed for MongoDB
```

### 5. Start Development Server
```bash
npm run dev
```

Application will be available at http://localhost:3000

## IDE Setup

### VSCode

Recommended extensions:
- ESLint
- Prettier
- GitLens
- Thunder Client (API testing)

Settings (.vscode/settings.json):
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": ["javascript", "javascriptreact"]
}
```

### WebStorm

1. Enable ESLint: Settings → Languages & Frameworks → JavaScript → Code Quality Tools → ESLint
2. Enable Prettier: Settings → Languages & Frameworks → JavaScript → Prettier
3. Configure Node.js: Settings → Languages & Frameworks → Node.js

## Git Hooks

Install git hooks:
```bash
bash .claude/hooks/install-hooks.sh
```

This installs pre-commit hooks that:
- Run ESLint
- Check test coverage (60% minimum)
- Validate JSDoc comments
- Auto-generate documentation

## Testing Setup

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

## Common Tasks

### Adding a New API Endpoint
1. Create route in `src/server/routes/`
2. Create controller in `src/server/controllers/`
3. Create service in `src/server/services/`
4. Add tests in `tests/`
5. Update API documentation

### Adding a New React Component
1. Create component in `src/client/components/`
2. Add JSDoc comments
3. Create tests in `src/client/components/__tests__/`
4. Export from index file if needed

### Database Migrations
```bash
# Create new migration
npm run migrate:create add_users_table

# Run migrations
npm run migrate

# Rollback last migration
npm run migrate:rollback
```

## Troubleshooting

**Port already in use**
```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>
```

**Database connection errors**
- Verify database is running
- Check DATABASE_URL in .env
- Verify database exists

**Module not found**
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```
```

## Generation Process

1. **Analyze Project**
   - Scan package.json for dependencies
   - Identify tech stack
   - Review project structure
   - Check existing documentation

2. **Generate Appropriate Sections**
   - Include only relevant sections
   - Customize for specific tech stack
   - Add project-specific configuration

3. **Verify Completeness**
   - All installation steps included
   - Environment variables documented
   - Common commands provided
   - Troubleshooting section added

4. **Update Existing Docs**
   - Preserve custom sections
   - Update outdated information
   - Maintain consistent formatting

## Best Practices

✅ Keep README concise but comprehensive
✅ Provide copy-paste ready commands
✅ Include example environment variables
✅ Document all prerequisites
✅ Add troubleshooting section
✅ Include links to detailed docs
✅ Update docs when code changes
✅ Test all commands before documenting

## Anti-Patterns to Avoid

❌ Outdated installation instructions
❌ Missing environment variable documentation
❌ No troubleshooting guidance
❌ Commands that don't work
❌ Too technical (assume beginner audience)
❌ Missing prerequisites
❌ No project structure documentation