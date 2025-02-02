import requests

import sys, json

def setStatus(t_ids, status, hostname, headers):
    for id in t_ids:
        requests.put(f"{hostname}/set/{id}/{status}", headers=headers)

def putComments(t, comments, hostname, headers):
    count = 0
    for c in comments:
        r = requests.post(
            hostname + "/comment/" + str(t["id"]),
            headers=headers,
            data=json.dumps({"content":c}))
        count += 1
        if r.status_code != 200:
            print(f"failed with count {count} and error {r.text}")
            exit(1)
    print(f"put {count} comments for task {t["id"]}")

def putTask(n, c, p, c_ids, hostname, headers):
    r = requests.post(
        hostname + "/new", 
        headers=headers, 
        data=json.dumps({"name":n, "cost":c, "priority":p, "categories":c_ids}))
    if r.status_code != 200:
        print(f"failed to put task with resp {r.text}")
        exit(1)
    return r.json()

def getComments(task):
    res = []
    for c in task["comments"]:
        res.append(c["content"])
    return res

def getCategoriesForTask(task, categoryMap):
    ids = []
    for c in task["categories"]:
        new_id = categoryMap[c["category_name"]]
        ids.append(new_id)
    return ids

def putTasks(data, categories, hostname, headers):
    t_ids = []
    for t in data:
        c = t["cost"]
        p = t["priority"]
        n = t["name"]
        c_ids = getCategoriesForTask(t, categories)
        comments = getComments(t)
        t_from_server = putTask(n, c, p, c_ids, hostname, headers)
        print(f"put task {t_from_server["id"]}")
        putComments(t_from_server, comments, hostname, headers)
        t_ids.append(t_from_server["id"])
    print(f"put {len(t_ids)} tasks")
    return t_ids

def pullCategories(hostname, headers):
    r = requests.get(hostname + "/category", headers=headers)
    if r.status_code != 200:
        print(f"failed to pull categories {r.status_code}\n{r.text}")
        exit(1)
    categories = r.json()
    resp = {}
    for c in categories:
        print(c)
        resp[c["category_name"]] = c["category_id"]
    return resp

def putCategories(categories, categories_from_server, hostname, headers):
    for c in categories:
        if c in categories_from_server:
            print(f"already know of the cateogry {c}")
            continue
        r = requests.post(hostname + "/category", 
            data=json.dumps({"name": c}), 
            headers=headers)
        if r.status_code == 200:
            print(f"put {c}")
        else:
            print(f"failed to put category of {c}\n{r.text}")
            return False
    return True

def getCategories(data):
    names = set()
    for t in data:
        for c in t["categories"]:
            names.add(c["category_name"])
    return names

# todo: process status data correctly
def processFile(file, status, hostname, bearer):
    data = {}
    with open(file) as f:
        data = json.loads(f.read())

    headers = {'Authorization': 'Bearer ' + bearer}

    categories = getCategories(data)
    categories_from_server = pullCategories(hostname, headers)

    success = putCategories(categories, categories_from_server, hostname, headers)
    if not success:
        print("failed!")
        exit(1)
    
    # pull again to get new category ids
    categories_from_server = pullCategories(hostname, headers)
    t_ids = putTasks(data, categories_from_server, hostname, headers)
    setStatus(t_ids, status, hostname, headers)

if __name__ == "__main__":
    tracking = sys.argv[1]
    completed = sys.argv[2]
    triaged = sys.argv[3]
    hostname = sys.argv[4]
    bearer = sys.argv[5]

    print("processing tracking")
    processFile(tracking, "tracking", hostname, bearer)
    print("processing completed")
    processFile(completed, "completed", hostname, bearer)
    print("processing triaged")
    processFile(triaged, "triaged", hostname, bearer)
