require "spec_helper"
require 'byebug'

describe Lita::Handlers::Gauth, lita_handler: true do
  it { is_expected.to be_truthy }
  # boiler plate stuff
  # should prob be moved out into shared context
  let(:robot) { Lita::Robot.new(registry) }
  let(:file_path) { './test_file_path' }
  let(:base_domain) { "http://uri.com/virgil" }
  let(:oauth_redir_path) { "/auth-redir" }
  let(:handler) { Lita::Handlers::Gauth.new robot }
  # subject { Lita::Handlers::Gauth.new(robot) }
  subject { handler }

  before do
    robot.config.handlers.gauth.client_id_hash = {
      "web" => {
        "client_id" => 3,
        "client_secret" => "super secret",
      }
    }

    robot.config.handlers.gauth.scopes = ["sheets"]
    robot.config.handlers.gauth.base_domain =  base_domain
    robot.config.handlers.gauth.oauth_redir_path = oauth_redir_path
    File.delete file_path if File.exist? file_path
    f = File.new file_path, 'w'
    f.close

    robot.config.handlers.gauth.data_file_path = file_path

    # end boilerplate
  end

  after { File.delete file_path }

  describe '#authed?' do
    let(:msgMock) {
      msgMock = double('msg')
      allow(msgMock).to receive(:reply)
      allow(msgMock).to receive(:user) { user }
      msgMock
    }

    it 'handles false' do
      allow(handler).to receive(:get_user_creds).and_return nil
      expect(msgMock).to receive(:reply).with(/not authed/)
      handler.check_auth msgMock
      # expect(replies[-2]).not_to match "not authed"
    end

    it 'handles true' do
      allow(handler).to receive(:get_user_creds).and_return true
      expect(msgMock).to receive(:reply).with(/ready to go/)
      handler.check_auth msgMock
    end
  end
end
