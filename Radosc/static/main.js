export function fetcher(url, callback, options = {})
{
    (async () =>
    {
        await fetch(url, options)
            .then( async response => callback(await response.json()) )
            .catch(error => console.log(error))
    })()
}

export async function sender(url, data)
{
    const response = await fetch(
        url,
        {
            method: "POST",
            headers:
            {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(data),
    })

    const json = await response.json()

    console.log("sending")
    return [json, response.status]
}

export function jwtToCookie(jwt)
{
    const cookies = new Cookies();
    const timestamp = JSON.parse(atob(jwt.token.split(".")[1])).exp
    const expireDate = new Date(timestamp * 1e3)
    console.log(jwt)
    console.log(expireDate)
    cookies.set("token", jwt.token, { path: "/", expires: expireDate, sameSite:"Lax" })
}

export function getToken()
{
    const cookies = new Cookies();
    return cookies.get("token")
}

export function expireTime()
{
    const cookies = new Cookies();
    let expireDate = 0
    const token = cookies.get("token")
    if (token === undefined)
        return 0
    const timestamp = JSON.parse(atob(token.split(".")[1])).exp
    expireDate = new Date(timestamp * 1e3)

    return expireDate
}

export function isLoggedIn()
{
    return expireTime() > 0
}


export function ifLoggedIn(then, otherWise=undefined)
{
    return isLoggedIn() ? then : otherWise
}


export function timeToExpire()
{
    return expireTime() - Date.now()
}

export class OfflineDatabase
{
    constructor(name, version, collection, key )
    {
        this.name = name
        this.version = version
        this.collection = collection
        this.key = key
        this.__prepareDB()
    }

    __prepareDB(callback)
    {
        const request = indexedDB.open(this.name, this.version)

        request.onupgradeneeded = (event) =>
        {
            let db = request.result
            db.createObjectStore(this.collection, {keyPath: this.key})
            alert(`Upgrade called, ${this.name}, ${this.version}`)
        }

        request.onsuccess = (event) =>
        {
            console.log(`Successuly opened database, ${this.name}, ${this.version}`)
        }

        request.onerror = e =>
        {
            alert(`Error called, ${e.target.error}`)
        }

    }

    async DB()
    {
        return new Promise(resolve =>
            {
                let request = indexedDB.open(this.name, this.version)
                request.onsuccess = () => resolve(request.result)
            })

    }

    async get(collection, id)
    {
        let db = await this.DB()

        let all = await new Promise(resolve =>
        {
            const request = db.transaction(collection, "readonly")
                            .objectStore(collection)
                            .get(id)

            request.onsuccess = () => resolve(request.result)
        })

        return all
    }

    async getAll(collection)
    {
        let db = await this.DB()

        let all = await new Promise(resolve =>
        {
            const request = db.transaction(collection, "readonly")
                            .objectStore(collection)
                            .getAll()

            request.onsuccess = () => resolve(request.result)
        })

        return all
    }

    async delete(collection, id)
    {
        let db = await this.DB()

        let all = await new Promise(resolve =>
        {
            const request = db.transaction(collection, "readwrite")
                            .objectStore(collection)
                            .delete(id)

            request.onsuccess = () => resolve(request.result)
        })

        return all
    }

    async deleteAll(collection)
    {
        let db = await this.DB()

        let all = await new Promise(resolve =>
        {
            const request = db.transaction(collection, "readwrite")
                            .objectStore(collection)
                            .clear()

            request.onsuccess = () => resolve(request.result)
        })

        return all
    }

    async createCollection(collection, key)
    {
        return new Promise(resolve =>
        {
            this.version += 1
            let request = indexedDB.open(this.name, this.version)
            request.onupgradeneeded = () => {
                let db = request.result
                db.createObjectStore(collection, {keyPath: key})
                resolve(request.result)
            }
        });
    }

    async deleteCollection(collection)
    {
        return new Promise(resolve =>
        {
            this.version += 1
            let request = indexedDB.open(this.name, this.version)
            request.onupgradeneeded = () =>
            {
                let db = request.result
                db.deleteObjectStore(collection)
                resolve(request.result)
            }
        });
    }

    async insert(collection, data)
    {
        let db = await this.DB()

        let all = await new Promise(resolve =>
        {
            const request = db.transaction(collection, "readwrite")
                            .objectStore(collection)
                            .put(data)

            request.onsuccess = () => resolve(request.result)
        })

        return all
    }
}

export function handleOffline(url, data, { db = "offDB", collection = "formData", key = "email" } = {})
{
    const isOnline = navigator.onLine //returns the online status of a browser
    if (isOnline)
    {
        return sender(url, data)
    }
    else
    {
        const idb = new OfflineDatabase(db, 1, collection, key)
        idb.insert("formData", data).then(e=>alert("Dane zapisano w przeglądarce. Zostaną wysłane po pojawieniu sę połączenia.", e))
    }

    return
}
