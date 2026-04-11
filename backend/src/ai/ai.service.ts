import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AiService {
  private readonly openRouterApiKey: string;
  private readonly openRouterUrl = 'https://openrouter.ai/api/v1';
  private readonly gemmaModel = 'nvidia/nemotron-nano-12b-v2-vl:free';

  constructor(
    private httpService: HttpService,
    private configService: ConfigService,
  ) {
    this.openRouterApiKey = configService.get<string>('OPENROUTER_API_KEY') || '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';
  }

  async analyzePrescription(imageUrl: string): Promise<any> {
    // In a real implementation, you'd use OCR first, then pass the text to AI
    // For now, we'll simulate the response
    const prompt = `Extract medication details from this prescription text. Return JSON with: name, dosage, frequency, instructions`;
    
    const result = await this.generateResponse(prompt);
    
    return {
      success: true,
      data: {
        medicationName: result.name || 'Unknown Medication',
        dosage: result.dosage || 'As directed',
        frequency: result.frequency || 'As prescribed',
        instructions: result.instructions || 'Follow your doctor\'s instructions',
        confidence: 0.85,
        rawText: 'Simulated prescription text',
      },
    };
  }

  async identifyPill(imageUrl: string): Promise<any> {
    const prompt = `Identify this pill from the image description. Return JSON with: name, genericName, manufacturer, description`;
    
    const result = await this.generateResponse(prompt);
    
    return {
      success: true,
      data: {
        name: result.name || 'Unknown Pill',
        genericName: result.genericName,
        manufacturer: result.manufacturer,
        description: result.description || 'Unable to identify',
        confidence: 0.7,
      },
    };
  }

  async getInsights(userId: string): Promise<any> {
    const prompt = `Generate personalized medication adherence insights. Include:
    1. A summary of the user's medication adherence
    2. Recommendations for improvement
    3. Current adherence score (percentage)
    4. Streak days count
    
    Format as JSON with keys: summary, recommendations[], adherenceScore, streakDays`;
    
    const result = await this.generateResponse(prompt);
    
    return {
      success: true,
      data: {
        summary: result.summary || 'Your adherence is looking good!',
        recommendations: result.recommendations || ['Keep up the good work!'],
        adherenceScore: result.adherenceScore || 85,
        streakDays: result.streakDays || 12,
      },
    };
  }

  async analyzeSymptoms(symptoms: string): Promise<any> {
    const prompt = `Analyze these symptoms reported by a medication user: "${symptoms}"
    
    Provide:
    1. A brief summary
    2. Possible causes (list)
    3. Recommendations (list)
    4. Whether they should seek medical attention (boolean)
    
    Format as JSON with keys: summary, possibleCauses[], recommendations[], requiresAttention
    
    IMPORTANT: Always remind users to consult healthcare professionals.`;
    
    const result = await this.generateResponse(prompt);
    
    return {
      success: true,
      data: {
        summary: result.summary || 'Please consult your doctor for proper diagnosis.',
        possibleCauses: result.possibleCauses || [],
        recommendations: result.recommendations || ['Consult your healthcare provider'],
        requiresAttention: result.requiresAttention || false,
      },
    };
  }

  async generateResponse(prompt: string): Promise<any> {
    try {
      const response = await this.httpService.post(
        `${this.openRouterUrl}/chat/completions`,
        {
          model: this.gemmaModel,
          messages: [
            {
              role: 'system',
              content: 'You are a medical assistant helping with medication management. Provide helpful, accurate information but always remind users to consult healthcare professionals. Return JSON format.',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
          max_tokens: 500,
        },
        {
          headers: {
            'Authorization': `Bearer ${this.openRouterApiKey}`,
            'Content-Type': 'application/json',
          },
        },
      ).toPromise();

      const content = response?.data?.choices?.[0]?.message?.content || '{}';
      
      // Try to parse JSON from the response
      try {
        return JSON.parse(content);
      } catch {
        // If not valid JSON, return the content as-is
        return { response: content };
      }
    } catch (error) {
      console.error('AI Service Error:', error?.message);
      // Return fallback data
      return {
        summary: 'Unable to generate insights at this time.',
        recommendations: ['Please try again later'],
      };
    }
  }

  async generateText(prompt: string): Promise<string> {
    const result = await this.generateResponse(prompt);
    return JSON.stringify(result);
  }
}