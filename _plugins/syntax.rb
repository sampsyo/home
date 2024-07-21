Jekyll::Hooks.register :site, :pre_render do |site|
  require "rouge"
  class BrilLexer < Rouge::RegexLexer
    title "Bril"
    tag "bril"

    def self.keywords
      @keywords ||= Set.new %w(const)
    end

    state :root do
      # The actual top level.
      rule /\s+/m, Text::Whitespace
      rule /@\w+/, Name::Function
      rule /\(/, Punctuation, :funcargs
      rule /\{/, Punctuation
      rule /\}/, Punctuation

      # I guess we just allow instructions anywhere.
      rule /(\w+)(\s*)(:)/ do |m|
        token Name::Variable, m[1]
        token Text::Whitespace, m[2]
        token Punctuation, m[3]
        push :valins
      end
      rule /(\.\w+)(:)/ do |m|
        token Name::Label, m[1]
        token Punctuation, m[2]
      end
      rule /\w+/, Keyword, :insargs
    end

    state :funcargs do
      rule /\s+/m, Text::Whitespace
      rule /(\w+)(\s*)(:)(\s*)(\w+)/ do |m|
        token Name::Variable, m[1]
        token Text::Whitespace, m[2]
        token Punctuation, m[3]
        token Text::Whitespace, m[4]
        token Keyword::Type, m[5]
      end
      rule /,/, Punctuation
      rule /(\))(\s*)(:)(\s*)(\w+)/ do |m|
        token Punctuation, m[1]
        token Text::Whitespace, m[2]
        token Punctuation, m[3]
        token Text::Whitespace, m[4]
        token Keyword::Type, m[5]
        pop!
      end
      rule /\)/, Punctuation, :pop!
    end

    state :valins do
      rule /\s+/m, Text::Whitespace
      rule /\w+/, Keyword::Type
      rule /\=/ do |m|
        token Punctuation
        goto :insbody
      end
      rule /;/, Punctuation, :pop!
    end

    state :insbody do
      rule /\s+/m, Text::Whitespace
      rule /\w+/ do |m|
        token Keyword
        goto :insargs
      end
      rule /;/, Punctuation, :pop!
    end

    state :insargs do
      rule /\s+/m, Text::Whitespace
      rule /\d+/, Literal::Number::Integer
      rule /@\w+/, Name::Function
      rule /(\.\w+)/, Name::Label
      rule /\w+/, Name::Variable
      rule /;/, Punctuation, :pop!
    end
  end
end
