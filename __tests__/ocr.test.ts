import { performOCR } from '@/lib/ocr'
import fs from 'fs'
import path from 'path'

describe('OCR Module', () => {
  it('should extract text from an image', async () => {
    // This test requires a test image file
    // Skip if not available
    const testImagePath = path.join(__dirname, 'fixtures', 'test-page.png')

    if (!fs.existsSync(testImagePath)) {
      console.log('Test image not found, skipping OCR test')
      return
    }

    const imageBuffer = fs.readFileSync(testImagePath)

    const results = await performOCR(imageBuffer, 'tesseract', {
      language: 'eng',
    })

    expect(results).toBeDefined()
    expect(Array.isArray(results)).toBe(true)
    expect(results.length).toBeGreaterThan(0)

    // Check structure of first result
    if (results.length > 0) {
      const firstResult = results[0]
      expect(firstResult).toHaveProperty('text')
      expect(firstResult).toHaveProperty('confidence')
      expect(firstResult).toHaveProperty('bbox')
      expect(firstResult.bbox).toHaveProperty('x')
      expect(firstResult.bbox).toHaveProperty('y')
      expect(firstResult.bbox).toHaveProperty('width')
      expect(firstResult.bbox).toHaveProperty('height')
    }
  }, 30000) // 30 second timeout for OCR
})
