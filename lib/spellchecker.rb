$:.unshift File.expand_path('../../lib', __FILE__)

require 'net/https'
require 'uri'
require 'rexml/document'
require 'open3'
require 'spellchecker/build_response'

module Spellchecker

  extend self

  @@aspell_path = "aspell"

  def aspell_path=(path)
    @@aspell_path = path
  end

  def aspell_path
    @@aspell_path
  end

  def check(text, lang='en')
    return [] unless valid_text?(text)

    command_output = do_spell_check(text, lang)
    build_response(text, command_output)
  end

  private

  def valid_text?(text)
    text != ''
  end

  def do_spell_check(text, lang)
   command   = [@@aspell_path, '-a', '-l', lang]
   stdout, _ = Open3.capture2(command.join(' '), stdin_data: text)

   raise 'Aspell command not found' if stdout == ''
   stdout
  end

  def build_response(text, spell_check_response)
    BuildResponse.new(text, spell_check_response).call
  end
end
