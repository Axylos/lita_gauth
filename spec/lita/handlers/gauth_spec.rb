require "spec_helper"

describe Lita::Handlers::Gauth, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }
  let(:file_path) { './test_file_path' }
  let(:base_uri) { "http://uri.com/auth-redir" }
  subject { Lita::Handlers::Gauth.new(robot) }
  let(:handler) { subject }

  before do
    robot.config.handlers.gauth.client_id_hash = {
      "web" => {
        "client_id" => 3,
        "client_secret" => "super secret",
      }
    }

    robot.config.handlers.gauth.scopes = ["sheets"]
    robot.config.handlers.gauth.base_uri =  base_uri
    File.delete file_path if File.exist? file_path
    f = File.new file_path, 'w'
    f.close

    robot.config.handlers.gauth.data_file_path = file_path
  end

  after { File.delete file_path }
  describe "#is_logged_in" do
    let(:auth_spy) { spy('VirtualResp') }
      
    it { is_expected.to route("Lita authed?").to :check_auth }

    it 'responds true or false' do
      send_message "Lita authed?"
      expect(replies[-2]).to eq "You are not authed"
    end

    it 'can call methods directly' do
      expect(auth_spy).to receive(:reply).with(/not auth/)
      subject.check_auth auth_spy
    end

    it 'listens for authorization requests' do
      send_message "Lita auth me"
      expect(replies.last).to match(base_uri)
      expect(replies.last).to match("auth-root")
    end
  end

  describe "#auth-root" do
    let(:user_id) { 5 }
    let(:auth_url) { "/auth-root/#{user_id}" }
    let(:storage_key) { "lita_gauth_user_id" }
    it { is_expected.to route_http(:get, "/auth-root/#{user_id}").to :auth_root }
    let(:resp) { resp = http.get auth_url }

    subject { resp.body }

    it { is_expected.not_to be_empty }

    it { is_expected.to match user_id.to_s }

    it { is_expected.to match storage_key }

    it { is_expected.to match base_uri }
  end

  describe "#oauth_callback" do
    let(:code) { '4/1asdfisafu334' }
    let(:storage_key) { "lita_gauth_user_id" }
    let(:redir_url) { "/auth-redir/?code=#{code}" }
    let(:resp) { http.get redir_url }
    let(:save_url) { "#{base_uri}/save-code/729/#{code}" }
    subject { resp.body }

    it { is_expected.to route_http(:get, redir_url).to(:auth_redir) }

    it { is_expected.not_to be_empty }

    it { is_expected.to match storage_key }

    it { is_expected.to match code }

    it { is_expected.to match base_uri }

    xit 'saves the api code' do
      code = '4/er7394sadfasdf'
      resp = http.get("/auth_redir?code=#{code}")
      resp;
    end
  end

  describe '#auth-save' do
    let(:user_id) { 1034834 }
    let(:code) { "4/3498afjsdlkjf30/rue" }
    let(:req_url) { "/auth-save/#{user_id}/?code=#{code}" }
    it { is_expected.to route_http(:get, req_url).to :auth_save }

    xdescribe 'handler' do
      let(:client) { double 'client' }
      let(:dbl) { handler }
      before do 
        allow(dbl).to receive :auth_client { client }
        subject { dbl }
      end

      it 'should not have an empty response' do
        resp = http.get req_url
        expect(resp.body).not_to be_empty
      end
    end

    xdescribe 'persistence' do
      let(:resp) { http.get req_url }

      it 'should call save creds' do
        http.get req_url
      end

      it 'should save the data' do
        expect(robot).not_to be_falsy
        expect(subject.get_user_creds(user_id)).to be_truthy
      end
      
    end
  end

end
