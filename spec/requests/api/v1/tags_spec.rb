require 'rails_helper'

RSpec.describe "Api::V1::Tags", type: :request do
  describe "获取标签" do
    it "未登录获取标签" do
      get '/api/v1/tags'
      expect(response).to have_http_status(401)
    end
    it "登录后获取标签" do
      user = User.create email: '1@qq.com'
      another_user = User.create email: '2@qq.com'
      11.times do |i| Tag.create name: "tag#{i}", user_id: user.id, sign: 'x' end
      11.times do |i| Tag.create name: "tag#{i}", user_id: another_user.id, sign: 'x' end

      get '/api/v1/tags', headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 10

      get '/api/v1/tags', headers: user.generate_auth_header, params: {page: 2}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
  end
  describe '创建标签' do
    it '未登录创建标签' do
      post '/api/v1/tags', params: {name: 'x', sign: 'x'}
      expect(response).to have_http_status(401)
    end
    it '登录后创建标签' do
      user = User.create email: '1@qq.com'
      post '/api/v1/tags', params: {name: 'name', sign: 'sign'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'name'
      expect(json['resource']['sign']).to eq 'sign'
    end
    it '登录后创建标签失败，因为没填 name' do
      user = User.create email: '1@qq.com'
      post '/api/v1/tags', params: {sign: 'sign'}, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['name'][0]).to eq "can't be blank"
    end
    it '登录后创建标签失败，因为没填 sign' do
      user = User.create email: '1@qq.com'
      post '/api/v1/tags', params: {name: 'name'}, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['sign'][0]).to eq "can't be blank"
    end
  end
end