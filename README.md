# CS3217 Problem Set 4

**Name:** Huang Weijie

**Matric No:** A0190270M

## Tips
1. CS3217's docs is at https://cs3217.github.io/cs3217-docs. Do visit the docs often, as
   it contains all things relevant to CS3217.
2. A Swiftlint configuration file is provided for you. It is recommended for you
   to use Swiftlint and follow this configuration. We opted in all rules and
   then slowly removed some rules we found unwieldy; as such, if you discover
   any rule that you think should be added/removed, do notify the teaching staff
   and we will consider changing it!

   In addition, keep in mind that, ultimately, this tool is only a guideline;
   some exceptions may be made as long as code quality is not compromised.
3. Do not burn out. Have fun!

## Dev Guide

### Project Structure

The source code for this application is divided into two major parts, the Physics engine
and the Peggle game itself.

The root directory of this repository is an XCode workspace, with the Physics engine in the
`Physics/` directory as a standalone Swift Package, and the Peggle game in the `Peggle/`
directory as a XCode project.

The source files in `Physics/` are arranged according to broad Physics concepts, with the
main entrypoint for clients being the `World` class in `Physics/World.swift`.

The source files in `Peggle/` are arranged according to a general MVVM structure, with different
folders with Views, ViewModels, Models, and others.

### General App Architecture

Generally, the application follows a MVVM architecture for the displays. The Physics engine package
handles all concerns related to simulating realistic physics. The logic for the game and the game designer (the "domain logic")
are mostly in the models. The views present the state in the models for various UI components, and the view models
are a thin layer that mediate the interaction between the models and the view.

### Physics Engine High Level Overview

The goal of the Physics engine is to simulate realistic physics motions for a set of rigid bodies. The engine:

- Can simulate gravity.
- Can handle collision detection, as well as resolving collisions between bodies.
- Supports bodies that collide, or pass through one another.
- Can simulate inelastic collisions (where energy is lost as heat).
- Can have unpassable boundaries on any of the left, right, top and bottom directions.
- Can simulate:
  - *dynamic* objects that behave like objects in the real world do
  - *static* objects that behave like some obstacles in games - immovable with seemingly infinite mass
  - *controlled* objects that behave like obstacles in games that move along a pre-determined path
- Exposes a set of callbacks, to allow clients to be notified of changes to bodies.

The non-goals of the engine is as follows:
- Only simulates *rigid* bodies that cannot be compressed or deformed
- Does not simulate friction or drag
- Does not simulate rotational or angular motion

The following is a high-level outline of the significant entities (ie. classes, structs, enums) used in the physics engine.

**`World`**

`World` is the top level class that orchestrates the physics simulation. Clients can add and remove
`RigidBodies` to and from the engine, along with callbacks that are fired when those bodies are updated.
Clients can also add boundaries to each direction (left, right, top, and bottom) of the world

To run the simulation, clients should call the `.update(dt: Float)` method and pass in a sufficiently 
small time interval. The simulation will then step forward by that time interval and run all the appropriate
simulations for that interval. Calling the update method ~30 to ~60 frames a second tends to result in smooth
simulations.

Each time the update method is called, the world has to run 4 major steps, in order:

1. Update the motion of every rigid body in the world. This means accounting for
   forces applied, velocity, and the body's current positions.
   
2. Check for collisions between all pairs of rigid bodies.
  This can be split into 2 phases, for performance, instead of brute forcing all pairs.
  - **Broad phase**: Generate *possible* groups of collisions
  - **Narrow phase**: Brute force each possible group to find the actual collisions
  
3. Resolve collisions by updating the motion of bodies such that they
   move away from each other in the next time step. If the time steps are
   small enough, this should result in realisitic collisions.
   
4. Send relevant callbacks to subscribers.

**`RigidBody`**

Every "object" inside the Physics world is represented as a `RigidBody`, which is updated on
every step of the world. `RigidBody` is very simple class which composes together various
other lower-level classes like `Geometry`, `Motion`, and `Material`. As a result, `RigidBody`
delegates most of its behavior to other entites, and the behavior of a `RigidBody` object can
be customized by swapping those entites out.

#### Collisions

Collisions involves 2 major areas, collision detection and collision resolution.

**`BroadPhaseCollisionDetector`**

As mentioned above, collision detection is done in two phases for performance, a
broad phase and a narrow phase. The `BroadPhaseCollisionDetector` is a protocol
which allows various `BroadPhase` objects to be added, updated and removed.

It can then return the list of candidate collision groups.

`SpatialHash` is a concrete implementation of this protocol which uses a spatial hash
to narrow down possible collisions.

**`Geometry`**

`Geometry` is an enum defining different shapes of geometry. It also contains the logic
required to detect collisions between each case of a geometric shape. This is how
narrow phase collision detection is done in this Physics engine. The rationale for why
`Geometry` is an enum has been covered in Problem Set 2's developer guide.

**`CollisionResolver`**

Collisions between objects must be resolved by pushing the objects apart somehow.
`CollisionResolver` is a protocol which defines 1 method that should be used to
resolve a given collision.

`ImpulseCollisionResolver` is a concrete implementation of this protocol which uses
impulses to resolve the collisions.

#### Dynamics

Dynamics determines how objects in the simulation move.

**`Motion`**

`Motion` is an enum that defines how objects move and react to external forces. There
are three cases, `dynamic`, `static` and `controlled`.

Dynamic objects react like normal objects in the real world. Their velocity can be affected
by external forces and impulses.

Static objects react like immovable game obstacles. They have a constant velocity, and forces
and impulses do not affect them.

Controlled objects move along pre-defined controlled routes. Their position can be controlled
by user defined code, and their velocity is based of their instantaneous change in position.
Forces and impulses also do not affect them.

### Peggle Game High Level Overview

The following is a high-level outline of the significant entities (ie. classes, structs, enums) used in the physics engine.

#### Models

There are various structs that represent each game object and encapsulate their logic. These include:

- `Peg`
    - Interactive pegs are your standard pegs that light up when hit, and are removed at the end of the round
    - Non-interactive pegs are your blocks, that function mainly as obstacles
- `Ball`
- `Cannon`
- `Bucket`
- `Explosion`

**`PeggleGameEngine`**

`PeggleGameEngine` orchestrates between the above game objects and the Physics engine to run the game.
It is in charge of encoding higher level game logic that cannot be represented in the Physics engine.
Examples include:

- Initiating the firing of the ball
- Checking to see if the ball is out of bounds
- Removing pegs and allowing the cannon to fire again if the ball is out of bounds.
- Coordinating between the physics engine and the game objects.
- Logic for powerups such as moving the ball for the Spooky powerup and creating explosions
  for the Kaboom powerup.

Similar to the Physics engine, `PeggleGameEngine` should be run by calling the `.update(dt: Float)`
method to progress the simulation forward by that timestep.

**`CoordinateMapper`**

`CoordinateMapper` is a protocol which maps coordinates from a local coordinate system to an
external coordinate system. Handling the mismatch between coordinate systems is an important
issue as the `PeggleGameEngine` and the physics engine run on their own set of coordinate
systems, while clients may have different coordinate systems.

For example, iOS has the 0 y-coordinate at the top-most point, while the physics engine has it flipped.

`ProportionateCoordinateMapper` is a concrete implementation of that protocol which maps coordinates
in a proportionate manner along both axes.

**`PowerupManager`**

`PowerupManager` is a dependency of the `PeggleGameEngine` that helps to manage the activated powerups. It is
in charge of keeping track of what powerups are active and removing the powerups when they have expired. It will
also apply any active powerups every tick.

The powerups themselves (ie. Spooky Powerup or Kaboom Powerup) contain the logic of how to update the game when
they are triggered. For example, the Spooky powerup checks for the position for the ball every tick, and transports
the ball to the top if the ball is ever out of bounds.

**`PhysicsEngineBrige`**

Simple class that bridges between the Peggle game engine and the physics engine. Helps to keep track of insertion/removal
of rigid bodies for each type of game objects, and also simplifies most of the mapping of coordinates in one place.

#### ViewModels and Views

The game has 1 main view and 1 main view model supporting that view. The view simply shows the
running game, and allows the user to fire the cannon at the appropriate times. There are also
several subviews that ecapsulate separate functionality, like the `GameMenuView` and `LevelSelectionView`.

**`GameViewModel`**

`GameViewModel` is a simple view model that mainly initializes the game engine, and starts the game
loop by hooking into `CADisplayLink`. Once the game loop starts, the game mostly runs on its own,
and updates to the game objects are propagated via implementing the `ObservableObject` protocol.

Each time the game engine updates objects, it runs a callback that the view model passes it. This
callback is used to
[manually publish updates via the `objectWillChange` property](https://www.hackingwithswift.com/quick-start/swiftui/how-to-send-state-updates-manually-using-objectwillchange).

Finally, `GameViewModel` exposes 1 method, `.fireBallWith(cannonAngle: Degrees)` for the view to
call when the cannon has been tapped by the user.

**`GameView`**

`GameView` is the view that displays the running game. It has multiple sub-views to display each
game object, such as `PegView`, `BallView` and `CannonView`. The view is rather simple and only
has one notable point of interaction, where users tap on the rotating cannon the fire the ball
in the direction the cannon is facing.

### Peggle Level Designer High Level Overview

The following is a high level overview of the significant entities (ie. classes, 
structs, enums) used in the level designer segment of the app:

#### Models

**`LevelBlueprint`**

`LevelBlueprint` is the representation of a Peggle level created by the level designer.
In the context of a level designer, the blueprint must have the following capabilities:

- Contain a collection of game objects, called `Peg`s, and support the adding and
  removal of pegs.
- Have a coordinate system, as the pegs are placed at specific points on the level,
  and the level has boundaries based on what is displayed on the screen.
- Able to check if a given peg placement is valid, ie. pegs that overlap with other
  pegs or the boundaries of the level are invalid.
  
Given that, the `LevelBlueprint` has a width and height with origin at (0, 0) to mimic
a 2D coordinate system, and an internal data structure to manage the pegs placed.

The height of the level can be updated to accomodated for arbitrarily tall levels.

It also has methods for adding pegs, removing pegs, as well as checking if a peg
can be placed at a particular spot.

Checking if the peg can be placed at a particular spot requires some hitbox collision
detection logic, which is implemented by `Geometry`.

**`PegBlueprint`**

`Peg` is the representation of peg blueprints that are placed on the level via the level designer.
Each peg has a color, is centered on a particular point, and has a certain hitbox, based
on the type of peg. For now, round and triangular pegs are supported.

These pegs can be rotated and resized by clicking on the peg in the level designer to open an
`EditPegView` which exposes sliders to control the rotation angle and scale of the peg.

**`RelativelySized`**

`RelativelySized` is a protocol that determines how each game object should be sized relative to
each other. This allows for a semi-consistent diplay of the game on various screen sizes.

Since aspect ratios of screens can differ, we do not define the relative size in 2 dimensions, 
as that would lead to warped aspect ratios for some game objects. Instead, we only allow Peggle
to be played on portrait oriented views, and we compare the relative sizes of game objects by
their widths, which is the more limiting axis for portrait oriented views.

This leads to the game objects having *roughly* the same relative size.

#### ViewModels and Views

The level designer has 1 main view and 1 main view model supporting that view. It also has several
sub-views that help to encasulate logic, such as the `EditPegView`. The requirements of
these views are:

- Add, remove and move around pegs on the screen based on different gestures
- Change between different modes of adding pegs of different colors, and removing pegs
- Editing existing pegs on the blueprint by changing their rotation/size
- Saving, loading, and resetting the level blueprint

**`LevelDesignerViewModel`**

`LevelDesignerViewModel` is the view model handling all the above requirements. It implements the
`ObservableObject` protocol, which allows SwiftUI to know to re-render the view when any of its
`@Published` attributes change. This is used to propagate changes in the model back to the view.

It interacts with a `LevelBlueprint`, and exposes methods for the view to call to mutate the
blueprint depending on the gesture taken.

It also tracks the current edit mode selected by the user, and changes the behavior of methods
based on it.

Lastly, it also interacts with the data layer, to handle the save and load logic when the
corresponding buttons are pressed on the view.

**`LevelDesignerView`**

The main view for the level designer. It displays the controls at the top, followed by the level
blueprint where pegs can be added below the controls. The state to be rendered (ie. what pegs should
be rendered) is all within the `LevelDesignerViewModel`. When published attributes in the view model
changes, SwiftUI re-renders this view with the updated data.

**`PegBlueprintView`**

A view for an individual peg blueprint. Handles how to properly display the peg and the callback logic
for all the gestures that can be made on a peg. Also handles the logic of animating the "drag to move peg"
action.

**`EditPegView`**

Encapulates the view code that allows players to edit pegs in the level designer. When a peg is tapped,
an edit panel is shown with sliders to control the editable components of a peg blueprint.

#### Data Layer

**`LevelBlueprintRepo` and `LevelBlueprintFileRepo`**

`LevelBlueprintRepo` is a protocol that defines the signature of how a level blueprint should be 
loaded and saved. `LevelBlueprintFileRepo` is a concrete implementation of that protocol that saves
and loads level blueprints as JSON encoded files. It is called by the view model when the "save" or
"load" buttons are pressed.



### Class Diagram

Below is a high-level class diagram outlining the interactions between entities.

#### Physics Engine

![Physics Class Diagram](./ps4-physics-engine-class-diagram.png)

#### Peggle

![Peggle Class Diagram](./ps4-peggle-class-diagram.png)

#### Level Designer

![Level Designer Class Diagram](./ps4-level-designer-class-diagram.png)


## Rules of the Game
Please write the rules of your game here. This section should include the
following sub-sections. You can keep the heading format here, and you can add
more headings to explain the rules of your game in a structured manner.
Alternatively, you can rewrite this section in your own style. You may also
write this section in a new file entirely, if you wish.

### Cannon Direction
Please explain how the player moves the cannon.

### Win and Lose Conditions
Please explain how the player wins/loses the game.

## Level Designer Additional Features

### Peg Rotation
Please explain how the player rotates the triangular pegs.

### Peg Resizing
Please explain how the player resizes the pegs.

## Bells and Whistles
Please write all of the additional features that you have implemented so that
your grader can award you credit.

## Tests
If you decide to write how you are going to do your tests instead of writing
actual tests, please write in this section. If you decide to write all of your
tests in code, please delete this section.

## Written Answers

### Reflecting on your Design
> Now that you have integrated the previous parts, comment on your architecture
> in problem sets 2 and 3. Here are some guiding questions:
> - do you think you have designed your code in the previous problem sets well
>   enough?
> - is there any technical debt that you need to clean in this problem set?
> - if you were to redo the entire application, is there anything you would
>   have done differently?

Your answer here
