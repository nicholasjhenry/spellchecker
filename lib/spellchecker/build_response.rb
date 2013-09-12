class Spellchecker
  class BuildResponse
    ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)

    def initialize(text, command_output)
      @text, @command_output = text, command_output
    end

    def call
      response     = extract_original_string_tokens(text)
      results      = extract_results(command_output)
      result_index = 0

      response.each_with_index do |word_hash, index|
        build_response_element(response[index], word_hash, results, result_index)
      end

      response
    end

    private

    attr_reader :text, :command_output

    def extract_original_string_tokens(text)
      text.split(' ').collect { |original| {:original => original} }
    end

    def extract_results(command_output)
      command_output.split("\n").slice(1..-1)
    end

    def build_response_element(response_element, word_hash, results, result_index)
      if valid_word?(word_hash[:original])
        if correct_spelling?(results[result_index])
          response_element.merge!(:correct => true)
        else
          suggestions = extract_suggestions(results[result_index])
          response_element.merge!(:correct => false, :suggestions => suggestions)
        end
        result_index += 1
      else
        response_element.merge!(:correct => true)
      end
    end

    def valid_word?(word)
      word =~ /[a-zA-z\[\]\?]/
    end

    def correct_spelling?(result_line)
      !(result_line =~ ASPELL_WORD_DATA_REGEX)
    end

    def extract_suggestions(result_line)
      result_line.split(':')[1].strip.split(',').map(&:strip)
    end
  end
end
