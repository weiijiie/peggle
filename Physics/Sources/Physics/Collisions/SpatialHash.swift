//
//  SpatialHash.swift
//  Peggle

public struct SpatialHash<T: BroadPhaseObject>: BroadPhaseCollisionDetector {

    public typealias Object = T

    struct CellIndex: Hashable {
        let x: Int
        let y: Int
    }

    private(set) var spatialHash: [CellIndex: [T]] = [:]
    // Keeps track of the indices in the hash where each object is stored
    private(set) var idToCellIndices: [T.ID: [CellIndex]] = [:]

    public let cellSize: Double

    public init(cellSize: Double) {
        self.cellSize = cellSize
    }

    public mutating func addBroadPhaseObject(_ object: T) {
        guard idToCellIndices[object.id] == nil else {
            return
        }

        // Since the object should be fully contained in its bounding box,
        // we add the object to all cells it could potentially intersect with.
        let indices = cellIndicesFor(object: object)
        for idx in indices {
            addObjectAt(idx: idx, object: object)
        }

        idToCellIndices[object.id] = indices
    }

    public mutating func removeBroadPhaseObject(_ object: T) {
        let indices = idToCellIndices.removeValue(forKey: object.id) ?? []
        for idx in indices {
            removeObjectAt(idx: idx, object: object)
        }
    }

    public mutating func updateBroadPhaseObject(_ object: T) {
        removeBroadPhaseObject(object)
        addBroadPhaseObject(object)
    }

    public func getCandidateCollisionGroups() -> [CandidateCollisionGroup] {
        spatialHash
            .filter { $0.value.count > 1 }
            .map { $0.value }
    }

    /// Returns the indices of all the cells for which the given object may intersect.
    private func cellIndicesFor(object: T) -> [CellIndex] {
        let (minX, maxX, minY, maxY) = object.boundingBox

        // To handle the case where the object overlaps multiple cells,
        // we can get the bottom left (min) and top right (max) points
        // of the bounding box. We can then compute the cells that those
        // points should hash to.
        let minCellIdx = cellIndexAt(point: Point(x: minX, y: minY))
        let maxCellIdx = cellIndexAt(point: Point(x: maxX, y: maxY))

        var indices: [CellIndex] = []

        for x in minCellIdx.x...maxCellIdx.x {
            for y in minCellIdx.y...maxCellIdx.y {
                let idx = CellIndex(x: x, y: y)
                indices.append(idx)
            }
        }

        return indices
    }

    private func cellIndexAt(point: Point) -> CellIndex {
        CellIndex(x: Int(point.x / cellSize), y: Int(point.y / cellSize))
    }

    private mutating func addObjectAt(idx: CellIndex, object: Object) {
        // Here we remove the array before appending to avoid triggering
        // copy-on-write behavior.
        var objectsInCell = spatialHash.removeValue(forKey: idx) ?? []
        objectsInCell.append(object)

        spatialHash[idx] = objectsInCell
    }

    private mutating func removeObjectAt(idx: CellIndex, object: Object) {
        // Remove before mutation, similar logic as above.
        var objectsInCell = spatialHash.removeValue(forKey: idx) ?? []
        objectsInCell.removeAll { $0.id == object.id }

        spatialHash[idx] = objectsInCell
    }
}
