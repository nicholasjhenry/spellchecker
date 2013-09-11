class Spellchecker
  class BuildResponse
    ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)

    def initialize(text, command_output)
      @text, @command_output = text, command_output
    end

    def call
      response = extract_original_string_tokens(text)
      results = command_output.split("\n").slice(1..-1)
      result_index = 0
      response.each_with_index do |word_hash, index|
        build_response_element(response, word_hash, index, results, result_index)
      end

      response
    end

    private

    attr_reader :text, :command_output

    def extract_original_string_tokens(text)
      text.split(' ').collect { |original| {:original => original} }
    end

    def build_response_element(response, word_hash, index, results, result_index)
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
end
