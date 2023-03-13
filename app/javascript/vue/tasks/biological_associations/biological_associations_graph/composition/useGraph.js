import { reactive, computed, toRefs } from 'vue'
import {
  BiologicalAssociation,
  BiologicalAssociationGraph,
  Citation
} from 'routes/endpoints'
import {
  makeBiologicalAssociation,
  makeNodeObject,
  makeCitation,
  makeCitationPayload,
  makeGraph
} from '../adapters'
import {
  unsavedEdge,
  nodeCollectionObjectStyle,
  nodeOtuStyle,
  unsavedNodeStyle
} from '../constants/graphStyle.js'
import {
  parseNodeId,
  makeNodeId,
  isEqualNodeObject,
  isNetwork,
  getHexColorFromString
} from '../utils'
import { COLLECTION_OBJECT } from 'constants/index.js'

const EXTEND_GRAPH = [
  'biological_associations_biological_associations_graphs',
  'biological_associations',
  'citations'
]

const EXTEND_BA = ['subject', 'object', 'biological_relationship', 'citations']

function initState() {
  return {
    biologicalAssociations: [],
    nodeObjects: [],
    selectedNodes: [],
    selectedEdges: [],
    citations: [],
    layouts: {
      nodes: {}
    },
    settings: {
      isSaving: false
    },
    graph: makeGraph({})
  }
}

export function useGraph() {
  const state = reactive(initState())

  const nodes = computed(() =>
    Object.fromEntries(
      state.nodeObjects.map((obj) => {
        const nodeId = makeNodeId(obj)
        const isSaved = getBiologicalRelationshipsByNodeId(nodeId).some(
          (ba) => !!ba.id
        )
        const node = {
          name: obj.name
        }

        Object.assign(
          node,
          obj.objectType === COLLECTION_OBJECT
            ? nodeCollectionObjectStyle
            : nodeOtuStyle
        )

        if (!isSaved) {
          Object.assign(node, unsavedNodeStyle)
        }

        return [nodeId, node]
      })
    )
  )

  const edges = computed(() => {
    const baEdges = state.biologicalAssociations.map((ba) => {
      const edgeObject = {
        id: ba.id,
        source: makeNodeId(ba.subject),
        target: makeNodeId(ba.object),
        label: ba.biologicalRelationship.name,
        color: ba.color
      }

      if (ba.isUnsaved || ba.citations.some((c) => !c.id)) {
        Object.assign(edgeObject, unsavedEdge)
      }

      return [ba.uuid, edgeObject]
    })

    return Object.fromEntries(baEdges)
  })

  const currentGraph = computed(() => state.graph)
  const currentNodes = computed(() => state.selectedNodes)

  function resetStore() {
    Object.assign(state, initState())
  }

  function getCitationsFor(uuid) {
    return state.citations.filter((c) => c.objectUuid === uuid)
  }

  function addCitationFor(obj, citationData) {
    const citation = makeCitation({
      ...citationData,
      objectUuid: obj.uuid,
      objectType: obj.objectType
    })

    obj.citations.push(citation)

    return citation
  }

  const getBiologicalRelationshipsByNodeId = (nodeId) => {
    const obj = parseNodeId(nodeId)

    return state.biologicalAssociations.filter((ba) => {
      return (
        isEqualNodeObject(ba.object, obj) || isEqualNodeObject(ba.subject, obj)
      )
    })
  }

  const isGraphUnsaved = computed(() =>
    state.biologicalAssociations.some((ba) => ba.isUnsaved)
  )

  async function addBiologicalRelationship({
    subjectNodeId,
    objectNodeId,
    relationship
  }) {
    const nObj = parseNodeId(subjectNodeId)
    const nSub = parseNodeId(objectNodeId)

    const subject = state.nodeObjects.find((o) => isEqualNodeObject(o, nSub))
    const object = state.nodeObjects.find((o) => isEqualNodeObject(o, nObj))

    const biologicalAssociation = {
      id: undefined,
      uuid: crypto.randomUUID(),
      subject,
      object,
      biologicalRelationship: relationship,
      color: await getHexColorFromString(relationship.name),
      isUnsaved: true
    }

    state.biologicalAssociations.push(biologicalAssociation)
  }

  function getObjectByUuid(uuid) {
    return [state.graph, ...state.biologicalAssociations].find(
      (item) => item.uuid === uuid
    )
  }

  function reverseRelation(uuid) {
    const ba = state.biologicalAssociations.find((ba) => ba.uuid === uuid)

    Object.assign(ba, {
      subject: ba.object,
      object: ba.subject,
      isUnsaved: true
    })
  }

  function setNodePosition(nodeId, position) {
    state.layouts.nodes[nodeId] = position
  }

  function addObject(obj) {
    if (!state.nodeObjects.some((item) => isEqualNodeObject(item, obj))) {
      state.nodeObjects.push(obj)
    }
  }

  async function loadGraph(graphId) {
    const params = { extend: EXTEND_GRAPH }
    const graph = makeGraph(
      (await BiologicalAssociationGraph.find(graphId, params)).body
    )
    const baIds = graph.biologicalAssociationIds.map(
      (ba) => ba.biological_association_id
    )

    resetStore()
    state.graph = graph
    state.layouts = JSON.parse(graph.layout)

    if (baIds.length) {
      await loadBiologicalAssociations(baIds)
    }

    return graph
  }

  async function loadBiologicalAssociations(ids) {
    return BiologicalAssociation.where({
      biological_association_id: ids,
      extend: EXTEND_BA
    }).then(async ({ body }) => {
      for (const item of body) {
        const ba = await makeBiologicalAssociation(item)

        addObject(ba.subject)
        addObject(ba.object)

        state.biologicalAssociations.push(ba)
      }
    })
  }

  function removeCitationFor({ obj, citation }) {
    const index = obj.citations.findIndex((item) => item.uuid === citation.uuid)

    return Citation.destroy(citation.id).then((_) => {
      obj.citations.splice(index, 1)
    })
  }

  function removeEdge(edgeId) {
    const index = state.biologicalAssociations.findIndex(
      (ba) => ba.uuid === edgeId
    )
    const ba = state.biologicalAssociations[index]

    if (ba.id) {
      BiologicalAssociation.destroy(ba.id).then((_) => {
        TW.workbench.alert.create(
          'Biological association was successfully deleted.',
          'notice'
        )
      })
    }

    state.biologicalAssociations.splice(index, 1)
  }

  function removeNode(nodeId) {
    const biologicalAssociations = getBiologicalRelationshipsByNodeId(nodeId)
    const created = biologicalAssociations.filter(({ id }) => id)
    const nodeObject = makeNodeObject(nodeId)

    biologicalAssociations.forEach((ba) => {
      removeEdge(ba.uuid)
    })

    const message =
      created.length > 1
        ? 'Biological association(s) were successfully deleted.'
        : 'Biological association was successfully deleted.'

    TW.workbench.alert.create(message, 'notice')

    removeNodeObject(nodeObject)

    state.biologicalAssociations = state.biologicalAssociations.filter(
      ({ uuid }) => biologicalAssociations.some((ba) => ba.uuid !== uuid)
    )
  }

  function removeNodeObject(obj) {
    const index = state.nodeObjects.findIndex((o) => isEqualNodeObject(o, obj))

    state.nodeObjects.splice(index, 1)
  }

  function saveBiologicalAssociations() {
    const biologicalAssociations = state.biologicalAssociations.filter(
      (ba) => ba.isUnsaved
    )

    const requests = biologicalAssociations.map((ba) => {
      const { biologicalRelationship, object, subject, id } = ba
      const payload = {
        biological_association: {
          biological_relationship_id: biologicalRelationship.id,
          biological_association_object_id: object.id,
          biological_association_object_type: object.objectType,
          biological_association_subject_id: subject.id,
          biological_association_subject_type: subject.objectType
        },
        extend: EXTEND_BA
      }

      const request = id
        ? BiologicalAssociation.update(id, payload)
        : BiologicalAssociation.create(payload)

      request.then(({ body }) => {
        ba.id = body.id
        ba.citations = body.citations
        ba.isUnsaved = false
      })

      return request
    })

    return Promise.all(requests)
  }

  async function save() {
    const createdBiologicalAssociations = await saveBiologicalAssociations()
    let biologicalAssociationGraph
    if (isNetwork(state.biologicalAssociations) || state.graph.id) {
      biologicalAssociationGraph = saveGraph()
    }

    const citations = await Promise.all([
      saveCitationsFor(state.graph),
      ...state.biologicalAssociations.map((ba) => saveCitationsFor(ba))
    ])

    return {
      biologicalAssociations: createdBiologicalAssociations,
      biologicalAssociationGraph,
      citations
    }
  }

  function saveCitationsFor(obj) {
    const unsaved = obj.citations.filter((c) => !c.id)

    const requests = unsaved.map((c) => {
      const payload = makeCitationPayload({ ...c, objectId: obj.id })

      return Citation.create({ citation: payload }).then(({ body }) => {
        const index = obj.citations.findIndex((item) => item.uuid === c.uuid)

        obj.citations[index] = makeCitation(body)
      })
    })

    return requests
  }

  function saveGraph() {
    const biologicalAssociationsSaved = state.biologicalAssociations.filter(
      (r) => r.id
    )
    const biologicalAssociationsInGraph =
      state.graph.biologicalAssociationIds.map(
        (obj) => obj.biological_association_id
      )

    const payload = {
      biological_associations_graph: {
        layout: JSON.stringify(state.layouts),
        biological_associations_biological_associations_graphs_attributes:
          biologicalAssociationsSaved
            .filter((ba) => !biologicalAssociationsInGraph.includes(ba.id))
            .map((r) => ({
              biological_association_id: r.id
            }))
      },
      extend: EXTEND_GRAPH
    }

    const request = state.graph.id
      ? BiologicalAssociationGraph.update(state.graph.id, payload)
      : BiologicalAssociationGraph.create(payload)

    request.then(({ body }) => {
      state.graph = makeGraph(body)
    })

    return request
  }

  return {
    addCitationFor,
    addBiologicalRelationship,
    addObject,
    currentGraph,
    currentNodes,
    edges,
    getBiologicalRelationshipsByNodeId,
    isGraphUnsaved,
    loadGraph,
    nodes,
    removeEdge,
    removeNode,
    resetStore,
    reverseRelation,
    save,
    saveBiologicalAssociations,
    setNodePosition,
    getCitationsFor,
    getObjectByUuid,
    removeCitationFor,
    ...toRefs(state)
  }
}
