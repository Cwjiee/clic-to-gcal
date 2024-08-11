require "tty-prompt"
PROMPT = TTY::Prompt.new

module Utils
  def normal_prompt(text)
    PROMPT.ask(text)
  end

  def secure_prompt(text)
    PROMPT.mask(text)
  end
end
