#!/usr/bin/env ruby

#crée un jeton d'accès personnel et un nouveau projet dans GitLab

repo_name = "gitlab-repo"

puts "Création d'un nouveau projet GitLab: #{repo_name}"

user = User.find_by_username("root")
if user.nil?
  puts "ERREUR: Utilisateur root non trouvé dans GitLab"
  exit 1
end
puts "Utilisateur root trouvé (ID: #{user.id})"

#token d'accès
token = user.personal_access_tokens.create(
  name: "script-token-#{Time.now.to_i}",
  scopes: ["api", "read_repository", "write_repository"],
  expires_at: 365.days.from_now
)

if token.persisted?
  puts "TOKEN_SUCCESS:#{token.token}"
  
  # Créer le projet
  project = Projects::CreateService.new(
    user,
    name: repo_name,
    path: repo_name,
    visibility_level: Gitlab::VisibilityLevel::PUBLIC,
    initialize_with_readme: true
  ).execute
  
  if project.persisted?
    puts "PROJECT_SUCCESS:#{project.full_path}"
    puts ""
    puts "=============== INSTRUCTIONS ==============="
    puts "Pour cloner le dépôt, utilisez:"
    puts "git clone http://oauth2:#{token.token}@gitlab.localhost/#{project.full_path}.git"
    puts "============================================"
  else
    puts "PROJECT_ERROR:#{project.errors.full_messages.join(", ")}"
  end
else
  puts "TOKEN_ERROR:#{token.errors.full_messages.join(", ")}"
end