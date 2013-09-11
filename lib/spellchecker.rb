$:.unshift File.expand_path('../../lib', __FILE__)

require 'net/https'
require 'uri'
require 'rexml/document'
require 'open3'
require 'spellchecker/build_response'

class Spellchecker

  @@aspell_path = "aspell"

  def self.aspell_path=(path)
    @@aspell_path = path
  end

  def self.aspell_path
    @@aspell_path
  end

  def self.check(text, lang='en')
    return [] unless valid_text?(text)

    command_output = do_spell_check(text, lang)
    build_response(text, command_output)
  end

  private

  def self.valid_text?(text)
    text != ''
  end

  def self.do_spell_check(text, lang)
   command   = [@@aspell_path, '-a', '-l', lang]
   stdout, _ = Open3.capture2(command.join(' '), stdin_data: text)

   raise 'Aspell command not found' if stdout == ''
   stdout
  end

  def self.build_response(text, spell_check_response)
    BuildResponse.new(text, spell_check_response).call
  end
end
