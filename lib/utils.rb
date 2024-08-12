require "tty-prompt"
require "tty-spinner"

PROMPT = TTY::Prompt.new
SPINNER = TTY::Spinner.new(format: :bouncing)

module Utils
  def normal_prompt(text)
    PROMPT.ask(text)
  end

  def secure_prompt(text)
    PROMPT.mask(text)
  end

  def choice_prompt(choice)
    PROMPT.yes?(choice)
  end

  def start_spinner
    SPINNER.auto_spin
  end

  def stop_spinner(text)
    SPINNER.stop(text)
  end
end
