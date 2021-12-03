//resource "aws_cognito_user_pool" "user_pool" {
//  name = "my-site-user-pool"
//
//  auto_verified_attributes = [
//    "email",
//  ]
//
//  mfa_configuration          = "OFF"
//  sms_authentication_message = "認証コードは {####} です。"
//
//  admin_create_user_config {
//    allow_admin_create_user_only = false
//    invite_message_template {
//      email_message = " ユーザー名は {username}、仮パスワードは {####} です。"
//      email_subject = " 仮パスワード"
//      sms_message   = " ユーザー名は {username}、仮パスワードは {####} です。"
//    }
//  }
//
//  email_configuration {
//    email_sending_account = "COGNITO_DEFAULT"
//  }
//
//  password_policy {
//    minimum_length                   = 8
//    require_lowercase                = true
//    require_numbers                  = true
//    require_symbols                  = true
//    require_uppercase                = true
//    temporary_password_validity_days = 7
//  }
//
//  schema {
//    attribute_data_type = "String"
//    name                = "email"
//    required            = true
//  }
//
//  username_configuration {
//    case_sensitive = true
//  }
//
//  verification_message_template {
//    default_email_option  = "CONFIRM_WITH_LINK"
//    email_message         = "検証コードは {####} です。"
//    email_message_by_link = "Eメールアドレスを検証するには、次のリンクをクリックしてください。{##Verify Email##} "
//    email_subject         = "検証コード"
//    email_subject_by_link = "検証リンク"
//    sms_message           = "検証コードは {####} です。"
//  }
//}
//
//
//resource "aws_cognito_user_pool_client" "user_pool_client" {
//  name         = "my-site-user-pool-client"
//  user_pool_id = aws_cognito_user_pool.user_pool.id
//
//  allowed_oauth_flows                  = []
//  allowed_oauth_flows_user_pool_client = false
//  allowed_oauth_scopes                 = []
//  callback_urls                        = []
//  explicit_auth_flows = [
//    "ALLOW_REFRESH_TOKEN_AUTH",
//    "ALLOW_USER_SRP_AUTH",
//    "ALLOW_USER_PASSWORD_AUTH",
//  ]
//  logout_urls                   = []
//  prevent_user_existence_errors = "ENABLED"
//  read_attributes = [
//    "address",
//    "birthdate",
//    "email",
//    "email_verified",
//    "family_name",
//    "gender",
//    "given_name",
//    "locale",
//    "middle_name",
//    "name",
//    "nickname",
//    "phone_number",
//    "phone_number_verified",
//    "picture",
//    "preferred_username",
//    "profile",
//    "updated_at",
//    "website",
//    "zoneinfo",
//  ]
//  refresh_token_validity       = 30
//  supported_identity_providers = []
//  write_attributes = [
//    "address",
//    "birthdate",
//    "email",
//    "family_name",
//    "gender",
//    "given_name",
//    "locale",
//    "middle_name",
//    "name",
//    "nickname",
//    "phone_number",
//    "picture",
//    "preferred_username",
//    "profile",
//    "updated_at",
//    "website",
//    "zoneinfo",
//  ]
//}