import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  async getAdherenceScore(userId: string, days: number = 30): Promise<any> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const logs = await this.prisma.doseLog.findMany({
      where: {
        userId,
        scheduledTime: { gte: startDate },
      },
    });

    const total = logs.length;
    const taken = logs.filter(l => l.intakeStatus === 'TAKEN').length;
    const adherenceRate = total > 0 ? (taken / total) * 100 : 0;

    return {
      success: true,
      data: {
        adherenceRate: Math.round(adherenceRate * 10) / 10,
        totalDoses: total,
        takenDoses: taken,
        missedDoses: logs.filter(l => l.intakeStatus === 'MISSED').length,
        period: days,
      },
    };
  }

  async getStreak(userId: string): Promise<any> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let streak = 0;
    let currentDate = new Date(today);

    while (true) {
      const dayStart = new Date(currentDate);
      const dayEnd = new Date(currentDate);
      dayEnd.setDate(dayEnd.getDate() + 1);

      const logs = await this.prisma.doseLog.findMany({
        where: {
          userId,
          scheduledTime: {
            gte: dayStart,
            lt: dayEnd,
          },
        },
      });

      if (logs.length === 0) break;

      const taken = logs.filter(l => l.intakeStatus === 'TAKEN').length;
      if (taken === 0) break;

      streak++;
      currentDate.setDate(currentDate.getDate() - 1);
    }

    return {
      success: true,
      data: {
        currentStreak: streak,
        longestStreak: streak, // Would need historical data for this
      },
    };
  }

  async getBodyImpact(userId: string): Promise<any> {
    // Calculate body impact based on adherence patterns
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const logs = await this.prisma.doseLog.findMany({
      where: {
        userId,
        scheduledTime: { gte: thirtyDaysAgo },
      },
    });

    const total = logs.length;
    const taken = logs.filter(l => l.intakeStatus === 'TAKEN').length;
    const adherenceRate = total > 0 ? taken / total : 0;

    // Calculate score based on various factors
    let score = 50; // Base score
    score += adherenceRate * 30; // Up to 30 points from adherence
    score += (total / 10); // Up to 3 points for consistent logging

    // Cap score at 100
    score = Math.min(100, Math.round(score));

    let summary = '';
    if (score >= 80) {
      summary = 'Excellent medication adherence! Your body is responding well to the treatment.';
    } else if (score >= 60) {
      summary = 'Good medication adherence. Keep up the consistent routine for better results.';
    } else {
      summary = 'Your medication adherence needs improvement. Consider setting more reminders.';
    }

    return {
      success: true,
      data: {
        score,
        summary,
        factors: [
          adherenceRate >= 0.8 ? 'High adherence rate' : 'Room for improvement in adherence',
          total >= 20 ? 'Consistent medication logging' : 'More regular logging needed',
        ],
        calculatedAt: new Date(),
      },
    };
  }

  async getAICoach(userId: string): Promise<any> {
    const adherence = await this.getAdherenceScore(userId, 30);
    const streak = await this.getStreak(userId);

    const recommendations: { title: string; description: string; priority: string; actionType: string }[] = [];

    if (adherence.data.adherenceRate < 80) {
      recommendations.push({
        title: 'Improve Adherence',
        description: 'Your adherence rate is below 80%. Try setting more reminders.',
        priority: 'high',
        actionType: 'reminder',
      });
    }

    if (streak.data.currentStreak > 7) {
      recommendations.push({
        title: 'Keep the Streak Going',
        description: `Great job maintaining a ${streak.data.currentStreak}-day streak!`,
        priority: 'medium',
        actionType: 'celebrate',
      });
    }

    // Check for low stock medications
    const medications = await this.prisma.medication.findMany({
      where: { userId, isActive: true, pillCount: { lte: 10 } },
    });

    if (medications.length > 0) {
      recommendations.push({
        title: 'Refill Needed',
        description: `${medications.length} medication(s) are running low.`,
        priority: 'high',
        actionType: 'refill',
      });
    }

    return {
      success: true,
      data: {
        title: 'AI Coach Insights',
        message: adherence.data.adherenceRate >= 80 
          ? "You're doing great! Keep up the excellent work." 
          : "Let's work together to improve your medication routine.",
        recommendations,
        calculatedAt: new Date(),
      },
    };
  }

  async getWeeklyStats(userId: string): Promise<any> {
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const logs = await this.prisma.doseLog.findMany({
      where: {
        userId,
        scheduledTime: { gte: weekAgo },
      },
      orderBy: { scheduledTime: 'asc' },
    });

    const dailyStats: { date: string; total: number; taken: number; missed: number }[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dayStart = new Date(date);
      dayStart.setHours(0, 0, 0, 0);
      const dayEnd = new Date(date);
      dayEnd.setHours(23, 59, 59, 999);

      const dayLogs = logs.filter(l => 
        l.scheduledTime >= dayStart && l.scheduledTime <= dayEnd
      );

      dailyStats.push({
        date: dayStart.toISOString().split('T')[0],
        total: dayLogs.length,
        taken: dayLogs.filter(l => l.intakeStatus === 'TAKEN').length,
        missed: dayLogs.filter(l => l.intakeStatus === 'MISSED').length,
      });
    }

    return {
      success: true,
      data: dailyStats,
    };
  }
}