function info() {
  var request = new XMLHttpRequest()
  request.open('POST', '/info', true)
  request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
  request.onload = function() {
    if (request.status >= 200 && request.status < 400) {
      var data = JSON.parse(request.responseText)
      fillField('input[name=title]', data['title'])
      fillField('textarea[name=description]', data['description'])
    } else {
      console.log('server error')
    }
  }
  request.onerror = function() {
    console.log('connection error')
  }
  request.send('url=' + document.querySelectorAll('input[name=url]')[0].value)
}

function fillField(selector, content) {
  field = document.querySelectorAll(selector)[0]
  if (field.value == "" && content != undefined) {
    field.value = content
  }
}
