resource "kubernetes_secret" "words_counter_batch" {
    metadata {
        name      = "secret-words-counter-batch"
        namespace = kubernetes_namespace.monitoring.metadata[0].name
    }

    data = {
        AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
        DB_ENDPOINT           = var.DB_ENDPOINT
        USERNAME              = var.USERNAME
        PASSWORD              = var.PASSWORD
        DB_NAME               = var.DB_NAME
        BUCKET_NAME           = var.BUCKET_NAME
        TABLE_NAME            = var.TABLE_NAME
    }
    type = "Opaque"
}

resource "kubernetes_secret" "grafana" {
    metadata {
        name      = "secret-grafana"
        namespace = kubernetes_namespace.monitoring.metadata[0].name
    }

    data = {
        DB_ENDPOINT                = var.DB_ENDPOINT
        USERNAME                   = var.USERNAME
        PASSWORD                   = var.PASSWORD
        DB_NAME                    = var.DB_NAME
        github_oauth_client_id     = var.github_oauth_client_id
        github_oauth_client_secret = var.github_oauth_client_secret
    }
    type = "Opaque"
}