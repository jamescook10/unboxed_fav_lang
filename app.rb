require "sinatra"
require "octokit"
require "./lib/github_user"
require './services/logger'

get "/" do
  erb :index
end

post "/favourite_language" do
  begin
    user = GithubUser.new(params[:username])
    favlang = user.favourite_languages

    case
    when favlang.empty?
      result = "#{user.username} does not appear to have any public repos with language information."
    when favlang.count == 1
      result = "#{user.username}'s favourite language is #{favlang.first}."
    when favlang.count > 1
      result = "#{user.username}'s favourite languages are #{favlang.join(", ")}."
    else
      result = "Something went wrong eeeek."
    end
  rescue GithubUser::NotFound => e
    result = "User could not be found."
  end

  erb :favourite_language, locals: {result: result}
end
