import Foundation

struct OvpHelper {
}

extension OvpHelper {
    static func getBbox(lat: Float64, lon: Float64, radiusKm: Float64) -> BoundingBox {
        let deltaLat = radiusKm / 111.32
        let deltaLon = radiusKm / (111.32 * cos(lat * .pi / 180))

        let minLat = lat - deltaLat
        let maxLat = lat + deltaLat

        let minLon = lon - deltaLon
        let maxLon = lon + deltaLon

        let bbox = BoundingBox(minLon: minLon, minLat: minLat, maxLon: maxLon, maxLat: maxLat)
        return bbox
    }
}

struct BoundingBox {
    let minLon: Float64
    let minLat: Float64
    let maxLon: Float64
    let maxLat: Float64
}

struct OutputTypes {
    static let json = "json"
}

protocol QueryParameter {
    var type: String { get }
    var parameters: [String]? { get }
    var filters: [String]? { get }
    var bbox: BoundingBox { get set }

    func format() -> String
}

extension QueryParameter {
    var parameters: [String]? { nil }
    var filters: [String]? { nil }

    func format() -> String {
        var query_string: String = ""
        if let ps = parameters, !ps.isEmpty {
            for p in ps {
                query_string += type + "[" + p + "]"
                query_string += "/n"
                if let fs = filters, !fs.isEmpty {
                    for f in fs {
                        query_string += "[" + f + "]"
                    }
                }
                query_string += "\n"
                query_string +=
                    "(" + String(bbox.minLon) + ","
                    + String(bbox.minLat) + ","
                    + String(bbox.maxLon) + ","
                    + String(bbox.maxLat) + ");"
            }
        } else {
            return ""
        }
        return query_string
    }
}

class QueryWay: QueryParameter {
    var type = "way"
    var parameters = ["highway"]
    var filters = [#"surface"~"asphalt|paved|concrete"#]
    var bbox: BoundingBox

    init(bbox: BoundingBox) {
        self.bbox = bbox
    }
}

class QueryNode: QueryParameter {
    var type = "node"
    var parameters = [
        #"amenity"~"fuel"#,
        #"tourism"~"viewpoint|attraction"#,
        #"highway"~"traffic_signals|stop"#,
    ]
    var bbox: BoundingBox

    init(bbox: BoundingBox) {
        self.bbox = bbox
    }
}

class QueryRelation: QueryParameter {
    var type = "relation"
    var bbox: BoundingBox
    init(bbox: BoundingBox) {
        self.bbox = bbox
    }
}

struct Query {
    var bbox: BoundingBox
    var output: String = OutputTypes.json
    var timeout: Int = 90
    var way: QueryWay
    var node: QueryNode
    var relation: QueryRelation
}

extension Query {
    func format() -> String {
        var query_string: String
        query_string = "[out:" + output + "]"
        query_string += "[out:" + String(timeout) + "]"
        query_string += "\n"
        query_string += "("
        query_string += way.format()
        query_string += "\n"
        query_string += node.format()
        query_string += "\n"
        query_string += relation.format()
        query_string += ");"
        // TODO: might need to also account for different outputs
        query_string += """
            out body;
            >;
            out skel qt;
            """
        return query_string
    }
}
