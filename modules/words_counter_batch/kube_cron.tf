# Doesn't work since can't attach secret to the CronJob
# resource "kubernetes_cron_job_v1" "words_counter_batch" {
#   metadata {
#     name = "words-counter-batch"
#   }
#   spec {
#     concurrency_policy            = "Replace"
#     failed_jobs_history_limit     = 5
#     schedule                      = "*/2 * * * *"
#     starting_deadline_seconds     = 10
#     successful_jobs_history_limit = 10
#     job_template {
#       metadata {}
#       spec {
#         backoff_limit              = 2
#         ttl_seconds_after_finished = 10
#         template {
#           metadata {}
#           spec {
#             container {
#               name     = "words-counter-batch"
#               image    = "ofirdassa/words-counter-batch:latest"
#             }
#           }
#         }
#       }
#     }
#   }
# }