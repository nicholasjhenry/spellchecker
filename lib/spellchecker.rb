class Spellchecker
  require 'net/https'
  require 'uri'
  require 'rexml/document'
  require 'open3'

  ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)

  @@aspell_path = "aspell"

  def self.aspell_path=(path)
    @@aspell_path = path
  end

  def self.aspell_path
    @@aspell_path
  end

  def self.check(text, lang='en')
    return [] if text == ''

    spell_check_response, _ = Open3.capture2("#{@@aspell_path} -a -l #{lang}", stdin_data: text)

    raise 'Aspell command not found' if spell_check_response == ''

    response = extract_original_string_tokens(text)
    results = spell_check_response.split("\n").slice(1..-1)
    result_index = 0
    response.each_with_index do |word_hash, index|
      build_response(response, word_hash, index, results, result_index)
    end

    response
  end

  private

  def self.extract_original_string_tokens(text)
    text.split(' ').collect { |original| {:original => original} }
  end

  def self.build_response(response, word_hash, index, results, result_index)
    if word_hash[:original] =~ /[a-zA-z\[\]\?]/
      if results[result_index] =~ ASPELL_WORD_DATA_REGEX
        suggestions = results[result_index].split(':')[1].strip.split(',').map(&:strip)
        response[index].merge!(:correct => false, :suggestions => suggestions)
      else
        response[index].merge!(:correct => true)
      end
      result_index += 1
    else
      response[index].merge!(:correct => true)
    end
  end
end
