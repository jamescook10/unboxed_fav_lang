require "sinatra"

class FavLang < Sinatra::Base
  get "/" do
    erb :index
  end
end
