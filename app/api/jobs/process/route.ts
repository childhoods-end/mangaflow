import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase/server'
import { processOcrJob, processTranslateJob, processRenderJob } from '@/lib/queue'
import logger from '@/lib/logger'

export const runtime = 'nodejs'
export const maxDuration = 300

/**
 * Job processor endpoint
 * Can be triggered by Vercel Cron or manually
 */
export async function POST(request: NextRequest) {
  try {
    // Get pending jobs
    const { data: jobs, error } = await supabaseAdmin
      .from('jobs')
      .select('*')
      .eq('state', 'pending')
      .lt('attempts', supabaseAdmin.from('jobs').select('max_attempts'))
      .order('created_at', { ascending: true })
      .limit(10)

    if (error || !jobs || jobs.length === 0) {
      return NextResponse.json({ processed: 0 })
    }

    const results = []

    for (const job of jobs) {
      try {
        // Mark as running
        await supabaseAdmin
          .from('jobs')
          .update({
            state: 'running',
            attempts: job.attempts + 1,
          })
          .eq('id', job.id)

        // Process based on job type
        switch (job.job_type) {
          case 'ocr':
            await processOcrJob(job.metadata.page_id, job.project_id)
            break
          case 'translate':
            await processTranslateJob(job.project_id)
            break
          case 'render':
            await processRenderJob(job.metadata.page_id, job.project_id)
            break
          default:
            throw new Error(`Unknown job type: ${job.job_type}`)
        }

        // Mark as done
        await supabaseAdmin
          .from('jobs')
          .update({ state: 'done' })
          .eq('id', job.id)

        results.push({ jobId: job.id, status: 'success' })
      } catch (error: any) {
        logger.error({ error, jobId: job.id }, 'Job processing failed')

        // Mark as failed if max attempts reached
        const newState = job.attempts + 1 >= job.max_attempts ? 'failed' : 'pending'

        await supabaseAdmin
          .from('jobs')
          .update({
            state: newState,
            last_error: error.message,
          })
          .eq('id', job.id)

        results.push({ jobId: job.id, status: 'failed', error: error.message })
      }
    }

    return NextResponse.json({ processed: results.length, results })
  } catch (error) {
    logger.error({ error }, 'Job processor failed')
    return NextResponse.json({ error: 'Failed to process jobs' }, { status: 500 })
  }
}
