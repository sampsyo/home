Jekyll::Hooks.register :site, :pre_render do |site|
  require "rouge"
  class BrilLexer < Rouge::RegexLexer
    title "Bril"
    tag "bril"

    def self.keywords
      @keywords ||= Set.new %w(const)
    end

    state :root do
      rule /\s+/m, Text::Whitespace
      rule /@\w+/, Name::Function
      rule /\{/, Punctuation, :function
    end

    state :function do
      rule /\s+/m, Text::Whitespace
      rule /(\w+)(:)/ do |m|
        token Name::Variable, m[1]
        token Punctuation, m[2]
        push :valins
      end
      rule /\w+/, Keyword, :insargs
      rule /\}/, Punctuation, :pop!
    end

    state :valins do
      rule /\s+/m, Text::Whitespace
      rule /\w+/, Keyword::Type
      rule /\=/, Punctuation, :insbody
      rule /;/ do |m|
        token Punctuation
        goto :function
      end
    end

    state :insbody do
      rule /\s+/m, Text::Whitespace
      rule /\w+/, Keyword, :insargs
      rule /;/ do |m|
        token Punctuation
        goto :function
      end
    end

    state :insargs do
      rule /\s+/m, Text::Whitespace
      rule /\d+/, Literal::Number::Integer
      rule /\w+/, Name::Variable
      rule /;/ do |m|
        token Punctuation
        goto :function
      end
    end
  end
end
