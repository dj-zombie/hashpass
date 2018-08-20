import axios from 'axios'


axios.interceptors.request.use(request => {
  const token = JSON.parse(localStorage.getItem('user'))
  if (token) {
    request.headers.common['Authorization'] = `Bearer ${token.token}`
  }
  return request
})

export default (function(){
  return{
    // Start/Stop
    start: function() { return axios.get('/api/start') },
    stop: function(id) { return axios.get('/api/stop/0') },

    // Pending
    get_pending:  function() { return axios.get('/api/pending') },
    create_pending: function(name, dictionary, dictionary2, rules,
        mask, hash, hashmode, hashstring, hashid) {
      return axios.post('/api/pending', {
        name: name,
        dictionary: dictionary,
        dictionary2: dictionary2,
        rules: rules,
        mask: mask,
        hash: hash,
        hashmode: hashmode,
        hashstring: hashstring,
        hashid: hashid
        })
    },
    clear_pending: function() { return axios.delete('api/pending') },

    // Dics
    get_dics: function() { return axios.get('/api/dics') },
    delete_dic: function(id) { return axios.delete('/api/dic/' + id) },
    insert_dic: function(name, location) {
      return axios.post('/api/dic', {
        name: name,
        location: location
        })
    },

    // Rules
    get_rules: function() { return axios.get('/api/rules') },
    delete_rule: function(id) { return axios.delete('/api/rule/' + id) },
    insert_rule: function(name, location) {
      return axios.post('/api/rule', {
        name: name,
        location: location
        })
    },

    // Users
    get_users: function() { return axios.get('/api/users') },
    delete_user: function(id) { return axios.delete('/api/user/' + id) },
    insert_user: function(name, password, role) {
      return axios.post('/api/user', {
        name: name,
        password: password,
        role: role
        })
    },

    // Hashes
    insert_hash: function(name, hash, hashmode, hashstring, latitude, longitude) {
      return axios.post('/api/hashes/insert', {
        name: name,
        hash: hash,
        hashmode: hashmode,
        hashstring: hashstring,
        latitude: latitude,
        longitude: longitude
        })
    },
    upload_hash: function() { return axios.post('/api/upload') },
    get_hashes:  function() { return axios.get('/api/hashes') },
    delete_hash: function(id) { return axios.delete('/api/hashes/' + id) },

    // History
    get_history:  function(id) { return axios.get('/api/history/' + id) },

    // Running
    get_running:  function() { return axios.get('/api/running') },
    clear_active: function() { return axios.delete('/api/running/clear') },
    promote_next: function() { return axios.get('/api/running/promote') },
    pid_active:   function(id) { return axios.get('/api/running/pid/' + id) },
    clear_running: function() { return axios.delete('api/running') },

    // Cracked
    get_cracked:  function() { return axios.get('api/cracked') },
    insert_cracked: function() { return axios.get('api/cracked/insert') },
    clear_cracked: function() { return axios.delete('api/cracked') },

    // Status
    get_progress: function() { return axios.get('/api/status') },

    // Authorization
    login: function(handle, password) {
      return axios.post('/hplogin', {
        handle: handle,
        password: password
      })
    }
  };
})();
