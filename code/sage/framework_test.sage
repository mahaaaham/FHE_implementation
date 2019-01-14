# read here for the explanations about colors:
# https://stackoverflow.com/questions/287871/print-in-terminal-with-colors
dict_color = {"red": "0;31;40", "green": "0;32;40", "purple": "1;35;40",
              "dark_over_yellow": "0;30;43",
              "dark_over_blue": "0;30;44"}


# a string printed with colors
def c_string(message, color):
    return "\x1b[" + dict_color[color] + "m" + message + "\x1b[0m"
