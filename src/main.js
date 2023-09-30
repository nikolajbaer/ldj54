import './index.css'
import { Clock,Vector3,Scene,PerspectiveCamera,WebGLRenderer,MeshBasicMaterial,BufferGeometry, GridHelper, BoxGeometry, LoopOnce, AudioLoader, InstancedMesh, Matrix4, Euler, Quaternion } from 'three'
import { defineComponent, defineQuery, createWorld,pipe, removeComponent,addComponent, hasComponent, entityExists, Types, addEntity, defineSystem } from 'bitecs';

async function init(){
  // Init Three Scene
  const scene = new Scene();
  const camera = new PerspectiveCamera( 30, window.innerWidth / window.innerHeight, 0.1, 1000 )
  camera.position.x = 0;  
  camera.position.y = 0;  
  camera.position.z = 200;  
  camera.lookAt(new Vector3(0,0,0))
  const renderer = new WebGLRenderer({antialias:true})
  renderer.setSize( window.innerWidth, window.innerHeight )
  document.getElementById('root').appendChild( renderer.domElement )
  const clock = new Clock();

  // Init Game ECS
  const world = createWorld()
  world.time = { delta: 0, elapsed: 0, then: performance.now() }
  const n = 1000
  const instanceMeshes = [
    new InstancedMesh(new BoxGeometry(),new MeshBasicMaterial({color:"red"}),n),
  ]
  instanceMeshes.forEach(m => scene.add(m))

  const timeSystem = world => {
    const { time } = world
    const now = performance.now()
    const delta = now - time.then
    time.delta = delta
    time.elapsed += delta
    time.then = now
    return world
  }

  // We build this system here to share scope with Three stuff
  const Vec3 = { x: Types.f32, y: Types.f32, z: Types.f32 }
  const Quat = { x: Types.f32, y: Types.f32, z: Types.f32, w: Types.f32 }
  const Position = defineComponent(Vec3)
  const Rotation = defineComponent(Quat)
  const Scale = defineComponent(Vec3)
  const Instance3d = defineComponent({type:Types.i8,index:Types.i16})
  const renderQuery = defineQuery([Position,Rotation,Scale,Instance3d])
  // Some temp instances to set for performance
  const tmpTransform = new Matrix4()
  const tmpQuat = new Quaternion()
  const tmpRotate = new Matrix4()
  const tmpScale = new Matrix4()
  const tmpVector = new Vector3()
  // Update render positions of instances
  const renderSystem = (world) => {
    renderQuery(world).forEach( (eid) => {
      const instanceMesh = instanceMeshes[Instance3d.type[eid]]
      const index = Instance3d.index[eid]
      tmpVector.set(Position.x[eid],Position.y[eid],Position.z[eid])
      tmpQuat.set(Rotation.x[eid],Rotation.y[eid],Rotation.z[eid],Rotation.w[eid])
      tmpTransform.makeTranslation(Position.x[eid],Position.y[eid],Position.z[eid])
        .premultiply(
          tmpRotate.makeRotationFromQuaternion(tmpQuat)
        ).premultiply(
          tmpScale.makeScale(Scale.x[eid],Scale.y[eid],Scale.z[eid])
        )
      instanceMesh.setMatrixAt(index,tmpTransform)
    })
    instanceMeshes.forEach(im => { im.instanceMatrix.needsUpdate = true })
    
    return world
  }

  // some basic logic spin things
  const spinSystem = (world) => {
    renderQuery(world).forEach( (eid) => {
      // TODO Rotate around center Y axis?
      //Rotation.x[eid] = tmpQuat.x += 0.001
    })
    return world
  }

  const pipeline = pipe(timeSystem,spinSystem,renderSystem)

  // Initialize some stuff
  for(let i=0;i<n;i++){
    const eid = addEntity(world)
    addComponent(world,Position,eid)
    addComponent(world,Rotation,eid)
    addComponent(world,Scale,eid)
    addComponent(world,Instance3d,eid)
    Instance3d.type[eid] = 0
    Instance3d.index[eid] = i
    Scale.x[eid] = 1
    Scale.y[eid] = 1
    Scale.z[eid] = 1
    Position.x[eid] = (Math.random()-0.5) * 100
    Position.y[eid] = (Math.random()-0.5) * 100
    Position.z[eid] = (Math.random()-0.5) * 100
  }

  // Resize Handler
  window.addEventListener( 'resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize( window.innerWidth, window.innerHeight );
  }, false );

  // Animate loop
  const animate = () => {
    const delta = clock.getDelta(); 
    pipeline(world)
  	requestAnimationFrame( animate )
  	renderer.render( scene, camera )
  }
  animate()
}

void init()