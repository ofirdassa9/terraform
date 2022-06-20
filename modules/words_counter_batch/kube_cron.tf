# Doesn't work since can't attach secret to the CronJob
resource "kubernetes_cron_job_v1" "words_counter_batch" {
  metadata {
    name = "words-counter-batch"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "55 23 * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name     = "words-counter-batch"
              # pulling image from my docker-hub repo
              image    = "ofirdassa/words-counter-batch:latest"
              env_from {
                secret_ref {
                    name = kubernetes_secret.words_counter_batch.metadata[0].name
                }
              }
            }
          }
        }
      }
    }
  }
}