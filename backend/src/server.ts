import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';

// Import configurations
import { connectDatabase } from '@/config/database';
import { connectRedis } from '@/config/redis';
import { logger } from '@/config/logger';

// Import middleware
import { errorHandler } from '@/middleware/errorHandler';
import { requestLogger } from '@/middleware/requestLogger';
import { authMiddleware } from '@/middleware/auth';
import { validateRequest } from '@/middleware/validation';

// Import routes
import healthRoutes from '@/routes/health';
import tokenRoutes from '@/routes/tokens';
import userRoutes from '@/routes/users';
import analyticsRoutes from '@/routes/analytics';
import adminRoutes from '@/routes/admin';

// Import services
import { BlockchainService } from '@/services/BlockchainService';
import { TokenService } from '@/services/TokenService';
import { AnalyticsService } from '@/services/AnalyticsService';
import { NotificationService } from '@/services/NotificationService';

// Load environment variables
dotenv.config();

class Server {
  private app: express.Application;
  private server: any;
  private io: SocketIOServer;
  private port: number;
  private host: string;

  constructor() {
    this.app = express();
    this.port = parseInt(process.env.PORT || '3001');
    this.host = process.env.HOST || 'localhost';
    
    this.initializeMiddleware();
    this.initializeRoutes();
    this.initializeErrorHandling();
    this.initializeServices();
  }

  private initializeMiddleware(): void {
    // Security middleware
    this.app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", "data:", "https:"],
        },
      },
    }));

    // CORS configuration
    this.app.use(cors({
      origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
      credentials: process.env.CORS_CREDENTIALS === 'true',
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    }));

    // Rate limiting
    const limiter = rateLimit({
      windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
      max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
      message: {
        error: 'Too many requests from this IP, please try again later.',
      },
      standardHeaders: true,
      legacyHeaders: false,
    });
    this.app.use(limiter);

    // Compression
    this.app.use(compression());

    // Body parsing
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Logging
    this.app.use(morgan('combined', {
      stream: {
        write: (message: string) => logger.info(message.trim()),
      },
    }));

    // Custom middleware
    this.app.use(requestLogger);
  }

  private initializeRoutes(): void {
    // Health check route
    this.app.use('/api/health', healthRoutes);

    // API routes
    this.app.use('/api/tokens', tokenRoutes);
    this.app.use('/api/users', userRoutes);
    this.app.use('/api/analytics', analyticsRoutes);
    this.app.use('/api/admin', adminRoutes);

    // Root route
    this.app.get('/', (req, res) => {
      res.json({
        message: 'Four.Meme Launchpad API',
        version: '1.0.0',
        status: 'running',
        timestamp: new Date().toISOString(),
      });
    });

    // 404 handler
    this.app.use('*', (req, res) => {
      res.status(404).json({
        error: 'Route not found',
        path: req.originalUrl,
        method: req.method,
      });
    });
  }

  private initializeErrorHandling(): void {
    this.app.use(errorHandler);
  }

  private initializeServices(): void {
    // Initialize services
    BlockchainService.getInstance();
    TokenService.getInstance();
    AnalyticsService.getInstance();
    NotificationService.getInstance();
  }

  private initializeSocketIO(): void {
    this.io = new SocketIOServer(this.server, {
      cors: {
        origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
        methods: ['GET', 'POST'],
        credentials: true,
      },
    });

    // Socket.IO event handlers
    this.io.on('connection', (socket) => {
      logger.info(`Client connected: ${socket.id}`);

      // Join token-specific rooms
      socket.on('join-token', (tokenAddress: string) => {
        socket.join(`token:${tokenAddress}`);
        logger.info(`Client ${socket.id} joined token room: ${tokenAddress}`);
      });

      // Leave token-specific rooms
      socket.on('leave-token', (tokenAddress: string) => {
        socket.leave(`token:${tokenAddress}`);
        logger.info(`Client ${socket.id} left token room: ${tokenAddress}`);
      });

      // Handle disconnection
      socket.on('disconnect', () => {
        logger.info(`Client disconnected: ${socket.id}`);
      });
    });
  }

  public async start(): Promise<void> {
    try {
      // Connect to databases
      await connectDatabase();
      await connectRedis();

      // Create HTTP server
      this.server = createServer(this.app);

      // Initialize Socket.IO
      this.initializeSocketIO();

      // Start server
      this.server.listen(this.port, this.host, () => {
        logger.info(`🚀 Server running on http://${this.host}:${this.port}`);
        logger.info(`📊 Environment: ${process.env.NODE_ENV}`);
        logger.info(`🔗 CORS Origin: ${process.env.CORS_ORIGIN}`);
      });

      // Graceful shutdown
      process.on('SIGTERM', this.gracefulShutdown.bind(this));
      process.on('SIGINT', this.gracefulShutdown.bind(this));

    } catch (error) {
      logger.error('Failed to start server:', error);
      process.exit(1);
    }
  }

  private async gracefulShutdown(): Promise<void> {
    logger.info('🛑 Graceful shutdown initiated...');

    try {
      // Close HTTP server
      if (this.server) {
        this.server.close(() => {
          logger.info('✅ HTTP server closed');
        });
      }

      // Close Socket.IO
      if (this.io) {
        this.io.close(() => {
          logger.info('✅ Socket.IO server closed');
        });
      }

      // Close database connections
      // Add database cleanup here

      logger.info('✅ Graceful shutdown completed');
      process.exit(0);
    } catch (error) {
      logger.error('❌ Error during graceful shutdown:', error);
      process.exit(1);
    }
  }

  public getApp(): express.Application {
    return this.app;
  }

  public getIO(): SocketIOServer {
    return this.io;
  }
}

// Start server
const server = new Server();
server.start().catch((error) => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});

export default server;
