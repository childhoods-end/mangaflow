import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-secondary">
      <div className="container mx-auto px-4 py-16">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <h1 className="text-5xl font-bold mb-4">MangaFlow</h1>
          <p className="text-xl text-muted-foreground mb-8">
            AI-Powered Manga Translation Platform
          </p>
          <div className="flex gap-4 justify-center">
            <Link href="/dashboard">
              <Button size="lg">Get Started</Button>
            </Link>
            <Link href="/auth/signin">
              <Button size="lg" variant="outline">
                Sign In
              </Button>
            </Link>
          </div>
        </div>

        {/* Features */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          <Card>
            <CardHeader>
              <CardTitle>OCR Processing</CardTitle>
              <CardDescription>
                Advanced OCR extracts text from manga panels with high accuracy
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm">
                Supports Japanese, Chinese, Korean, and other languages. Handles vertical text and
                speech bubbles.
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>AI Translation</CardTitle>
              <CardDescription>
                Multiple AI providers for natural manga translations
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm">
                Choose from Claude, GPT-4, or DeepL. Maintains manga tone and style with context
                awareness.
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Visual Editor</CardTitle>
              <CardDescription>Edit and refine translations with ease</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm">
                Adjust text positioning, fonts, and formatting. Preview changes in real-time before
                export.
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Pricing Preview */}
        <div className="text-center">
          <h2 className="text-3xl font-bold mb-8">Simple Pricing</h2>
          <div className="grid md:grid-cols-3 gap-6 max-w-4xl mx-auto">
            <Card>
              <CardHeader>
                <CardTitle>Free</CardTitle>
                <CardDescription>Perfect for trying out</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-3xl font-bold mb-4">$0</div>
                <ul className="text-sm space-y-2">
                  <li>3 projects</li>
                  <li>50 pages per project</li>
                  <li>Basic OCR & translation</li>
                </ul>
              </CardContent>
            </Card>

            <Card className="border-primary">
              <CardHeader>
                <CardTitle>Pro</CardTitle>
                <CardDescription>For regular users</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-3xl font-bold mb-4">$19/mo</div>
                <ul className="text-sm space-y-2">
                  <li>50 projects</li>
                  <li>500 pages per project</li>
                  <li>Priority processing</li>
                  <li>Advanced AI models</li>
                </ul>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Enterprise</CardTitle>
                <CardDescription>For teams & studios</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-3xl font-bold mb-4">Custom</div>
                <ul className="text-sm space-y-2">
                  <li>Unlimited projects</li>
                  <li>Unlimited pages</li>
                  <li>API access</li>
                  <li>Custom models</li>
                </ul>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t mt-16 py-8">
        <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
          <p>© 2025 MangaFlow. Built with Next.js, Supabase, and AI.</p>
        </div>
      </footer>
    </div>
  )
}
