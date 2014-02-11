window.DATE_FORMAT = 'YYYY-MM-DD HH:mm'

api_url = null

addQuestionInit = ->
  return null unless $('#add-question').length

  insertLocales = ($root, hash, type='label') ->
    $root.find("> fieldset > div.#{type}").each (_, block) ->
      $block = $(block)
      lang = $block.find('select.locale').val()
      text = $block.find("input.#{type}").val()
      hash[lang] = text

  $(document).on 'click', 'div.add a', ->
    $el = $(@).closest('.add')
    $bk = $el.prev()
    $cl = $bk.clone()
    $cl.find('input, select').val(null)
    $cl.insertAfter($bk)

  $(document).on 'click', 'div.remove a', ->
    $el = $(@).closest('div.remove').parent()
    if $el.prev().is('div.label, div.component, div.choice')
      $el.remove()
    else
      alert('Dernier de son genre...')

  $(document).on 'submit', 'form', (e) ->
    e.preventDefault()
    params = {labels: {}, components: [], expires_at: null}
    $form = $(@)

    expires_at = $form.find('> fieldset > input.expires_at').val()
    params.expires_at = expires_at

    insertLocales($form, params.labels)

    $form.find('> fieldset > div.component').each (_, component) ->
      componentHash = {labels: {}}
      $component = $(component)
      componentHash.kind = $component.find('select.kind').val()
      insertLocales($component, componentHash.labels)

      if componentHash.kind is '0' # choices
        componentHash.choices = {}
        insertLocales($component, componentHash.choices, 'choice')

      params.components.push(componentHash)

    $.ajax
      url: "http://#{api_url}/v1/admin/questions",
      type: 'POST'
      contentType: 'application/json',
      processData: false
      data: JSON.stringify
        token: $form.find('input.token').val()
        question: params
    .done ->
      alert('Done!')
    .fail ->
      console.log arguments
      alert('Fail!')

listQuestionsInit = ->
  $list = $('#questions-list')
  return null unless $list.length

  $.ajax
    url: "http://#{api_url}/v1/admin/questions"
    type: 'GET'
    data: { token: $('meta[name=token]').prop('content') }
  .done (questions) ->
    buffer = ''
    for question in questions
      buffer +=
        """
        <li class="question">
          <a href="/admin/questions/#{question.id}">#{question.labels.fr ? question.labels.en}</a>
          <span class="expires_at">#{moment(question.expires_at * 1000).format(DATE_FORMAT)}</span>
          <span class="stats participations">#{question.statistics.participations} participations</span>
          <span class="stats cristals">#{question.statistics.total} cistaux</span>
        </li>
        """
    $list.html(buffer)

$ ->
  # Set the api URL according to the host.
  if window.location.host is 'predictio.info'
    api_url = 'api.predictio.info'
  else
    api_url = window.location.host

  addQuestionInit()
  listQuestionsInit()
