public class Dockerly.ContainerDTO : Object {
    public string id { get; set; }
    public string names { get; set; }

    public ContainerDTO(Json.Object container) {
        this.id = container.get_string_member ("ID");
        this.names = container.get_string_member ("Names");
    }
}

//    "ID": "94a3470bcf73",
//    "Names": "postgres",
//    "Command": "\"docker-entrypoint.s…\"",
//    "CreatedAt": "2021-08-29 23:35:12 -0300 -03",
//    "Image": "postgres",
//    "Labels": "",
//    "LocalVolumes": "1",
//    "Mounts": "46c2390a839a2b…",
//    "Networks": "bridge",
//    "Ports": "",
//    "RunningFor": "5 days ago",
//    "Size": "370MB (virtual 685MB)",
//    "State": "exited",
//    "Status": "Exited (0) 5 days ago"