# Should we eventually include example ActiveSupport Notifications
# http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html

=begin
ActiveSupport::Notifications.instrument('render', extra: :information) do
  render text: 'Foo'
end

# Have the indexer subscribe to these notifications
ActiveSupport::Notifications.subscribe('render') do |name, start, finish, id, payload|
  name    # => String, name of the event (such as 'render' from above)
  start   # => Time, when the instrumented block started execution
  finish  # => Time, when the instrumented block ended execution
  id      # => String, unique ID for this notification
  payload # => Hash, the payload
end

=end