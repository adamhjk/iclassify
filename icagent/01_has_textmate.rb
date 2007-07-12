#
# The worlds simplest of Ruby DSL's.  Basically, this evals in the
# context of an instance of IClassify::Agent, who has already had
# the Node data loaded from the server.
#

add_tag('textmate') if File.exists?('/Applications/TextMate.app')
