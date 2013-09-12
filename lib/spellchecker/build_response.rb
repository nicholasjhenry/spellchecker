class Spellchecker
  class BuildResponse
    ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)

    def initialize(text, command_output)
      @text, @command_output = text, command_output
    end

    def call
      response     = extract_original_string_tokens(text)
      results      = extract_results(command_output)

      build_response_from_results(response, results)

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

    def build_response_from_results(response, results)
      result_index = 0
      response.each_with_index do |word_hash, index|
        build_response_element(response[index], word_hash[:original], results, result_index)
      end
    end

    def build_response_element(response_element, original_word, results, result_index)
      if !valid_word?(original_word)
        response_element.merge!(:correct => true)
        return
      end

      if correct_spelling?(results[result_index])
        response_element.merge!(:correct => true)
      else
        suggestions = extract_suggestions(results[result_index])
        response_element.merge!(:correct => false, :suggestions => suggestions)
      end

      result_index += 1

      response_element
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
