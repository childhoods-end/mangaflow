import { ModerationGateway } from '@/lib/moderation'

describe('Moderation Gateway', () => {
  const gateway = new ModerationGateway()

  it('should allow safe content', async () => {
    const result = await gateway.moderate({
      originalText: 'こんにちは',
      translatedText: 'Hello',
      contentRating: 'general',
    })

    expect(result.action).toBe('allow')
  })

  it('should enforce age restrictions', async () => {
    const result = await gateway.moderate({
      originalText: 'Adult content',
      translatedText: 'Adult content',
      contentRating: 'explicit',
      userAge: 16,
    })

    expect(result.action).toBe('block')
    expect(result.reason).toBe('age_restriction')
  })

  it('should flag keyword matches', async () => {
    const result = await gateway.moderate({
      originalText: 'This contains explicit content',
      translatedText: 'This contains explicit content',
      contentRating: 'general',
    })

    // Should flag or mask
    expect(['flag', 'mask']).toContain(result.action)
  })
})
