import ballerinax/github;
import ballerina/http;
import ballerina/io;

configurable string token = ?;

type Repository record {|
    string name;
    int? stargazerCount;
|};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for getting an array of repos with highest stars
    # + return - an array of repos or error
    resource function get stars/[string org]/[int count]() returns Repository[]?|error {
        // Send a response back to the caller.
        github:Client githubEp = check new (config = {
            auth: {
                token: token
            }
        });

        stream<github:Repository, github:Error?> repositories = check githubEp->getRepositories(org, true);        

        Repository[]? repoArray = check from github:Repository repo in repositories
            order by repo.stargazerCount descending
            limit count
            select {name:repo.name, stargazerCount:repo.stargazerCount};

        foreach var repo in repoArray ?: [] {
            io:println(repo.toString());
        }

        return repoArray;

    }
}
