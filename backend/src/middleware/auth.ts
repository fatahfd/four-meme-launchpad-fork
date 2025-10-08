import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from './errorHandler';
import { logger } from '@/config/logger';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    address: string;
    role: string;
  };
}

export const authMiddleware = (req: AuthRequest, res: Response, next: NextFunction): void => {
  /* Contact Me */
};

export const adminMiddleware = (req: AuthRequest, res: Response, next: NextFunction): void => {
  if (!req.user) {
    return next(new AppError('Authentication required', 401));
  }

  if (req.user.role !== 'admin' && req.user.role !== 'moderator') {
    return next(new AppError('Admin access required', 403));
  }

  next();
};

export const moderatorMiddleware = (req: AuthRequest, res: Response, next: NextFunction): void => {
  if (!req.user) {
    return next(new AppError('Authentication required', 401));
  }

  if (req.user.role !== 'moderator' && req.user.role !== 'admin') {
    return next(new AppError('Moderator access required', 403));
  }

  next();
};

export const optionalAuth = (req: AuthRequest, res: Response, next: NextFunction): void => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (token) {
      const jwtSecret = process.env.JWT_SECRET;
      if (jwtSecret) {
        const decoded = jwt.verify(token, jwtSecret) as any;
        req.user = decoded;
      }
    }
    
    next();
  } catch (error) {
    // Continue without authentication for optional auth
    next();
  }
};
