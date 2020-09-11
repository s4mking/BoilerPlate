export default {
    getToken: (username, password) => {
        return new Promise((resolve,reject) => {
            fetch("https://localhost:8443/api/login_check", {
                method: 'POST',
                headers: {
                    'Content-Type': "application/json"
                },
                body: JSON.stringify({"username": username ,"password": password })
            }).then((data) => {
                data.json().then((json) => {
                    if (json.token) {
                        localStorage.setItem("token", json.token);
                        resolve(json)
                    } 
                }).catch((errors)=>{
                    reject(errors)
                    console.log(errors)
                })
            })
        })
    },
    
    Register: (username, email, password) => {
        return new Promise((resolve, reject) => {
            fetch("https://localhost:8443/api/login_check", {
                method: 'POST',
                headers: {
                    'Content-Type': "application/x-www-form-urlencoded"
                },
                body: JSON.stringify({"username": username, "password": password})
            }).then((data) => {
                data.json().then((json) => {
                    resolve(json)
                }).catch((errors)=>{
                    reject()
                    console.error('errors',errors)
                })
            })
        })
    },
    
}