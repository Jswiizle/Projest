import 'package:firebase_auth/firebase_auth.dart';
import 'package:projest/models/objects/feedback_object.dart';
import '../models/objects/user_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/objects/project_object.dart';
import 'package:projest/models/objects/project_complaint_object.dart';
import 'package:projest/models/objects/blip_object.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthExceptionHandler {
  static handleException(e) {
    print("code is ${e.code}");
    var status;
    switch (e.code) {
      case "invalid-email":
        status = AuthResultStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthResultStatus.wrongPassword;
        break;
      case "user-not-found":
        status = AuthResultStatus.userNotFound;
        break;
      case "user-disabled":
        status = AuthResultStatus.userDisabled;
        break;
      case "too-many-requests":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "operation-not-allowed":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "email-already-in-use":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }

  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "The email address entered is not formatted properly.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Your password is wrong.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "User with this email has been disabled.";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Signing in with email and password is not enabled.";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage =
            "The email has already been registered. Please login or reset your password.";
        break;
      default:
        errorMessage = "Could not log in";
    }

    return errorMessage;
  }
}

class FirebaseAuthHelper {
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  AuthResultStatus _status;

  static UserObject loggedInUser;
  static User authUser;

  Future<void> setCurrentUser() async {
    await _firestore
        .collection('Users')
        .where('uid', isEqualTo: auth.currentUser.uid)
        .get()
        .then((value) {
      loggedInUser = UserObject.fromJson(value.docs.first.data());
      authUser = auth.currentUser;
    });
  }

  Future<AuthResultStatus> createAccount({email, pass}) async {
    try {
      final authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      if (authResult.user != null) {
        _status = AuthResultStatus.successful;
        authUser = auth.currentUser;
      } else {
        _status = AuthResultStatus.undefined;
      }
    } catch (e) {
      print('Exception @createAccount: $e');
      _status = AuthExceptionHandler.handleException(e);
    }
    return _status;
  }

  Future<AuthResultStatus> login({email, pass}) async {
    try {
      final authResult =
          await auth.signInWithEmailAndPassword(email: email, password: pass);

      if (authResult.user != null) {
        _status = AuthResultStatus.successful;
        await setCurrentUser();
      } else {
        _status = AuthResultStatus.undefined;
      }
    } catch (e) {
      print('Exception @createAccount: $e');
      _status = AuthExceptionHandler.handleException(e);
    }
    return _status;
  }

  logout() {
    auth.signOut();
  }
}

class FirestoreHelper {
  final _firestore = FirebaseFirestore.instance;
  final Function updateFailed;

  FirestoreHelper({this.updateFailed});

  Future<void> updateCurrentUser() async {
    await _firestore
        .collection('Users')
        .doc(FirebaseAuthHelper.loggedInUser.uid)
        .set(FirebaseAuthHelper.loggedInUser.toJson());

    if (FirebaseAuthHelper.loggedInUser.email !=
        FirebaseAuthHelper.authUser.email) {
      FirebaseAuthHelper helper = FirebaseAuthHelper();

      List<String> signInMethods = await helper.auth
          .fetchSignInMethodsForEmail(FirebaseAuthHelper.loggedInUser.email);

      if (signInMethods.length == 0) {
        await helper.auth.currentUser.reauthenticateWithCredential(
            EmailAuthProvider.credential(
                email: helper.auth.currentUser.email,
                password: FirebaseAuthHelper.loggedInUser.password));
        await helper.auth.currentUser
            .updateEmail(FirebaseAuthHelper.loggedInUser.email);
        await helper.setCurrentUser();
      } else {
        FirebaseAuthHelper.loggedInUser.email =
            FirebaseAuthHelper.authUser.email;
        updateFailed();
      }
    }
  }

  Future<void> addFcmToken(String token) async {
    FirebaseAuthHelper.loggedInUser.fcmTokens.add(token);

    await updateCurrentUser();

    //Update user's projects

    await _firestore
        .collection('Projects')
        .where('uid', isEqualTo: FirebaseAuthHelper.loggedInUser.uid)
        .get()
        .then((p) async {
      if (p.docs.length > 0) {
        for (var d in p.docs) {
          ProjectObject project = ProjectObject.fromJson(d.data());
          project.ownerTokens = FirebaseAuthHelper.loggedInUser.fcmTokens;
          await updateProject(project);
        }
      }
    });

    //Update feedback given

    await _firestore
        .collection('Projects')
        .where('ratedByUids',
            arrayContains: FirebaseAuthHelper.loggedInUser.uid)
        .get()
        .then((p) async {
      if (p.docs.length > 0) {
        for (var d in p.docs) {
          ProjectObject project = ProjectObject.fromJson(d.data());

          for (var f in project.feedbackArray) {
            FeedbackObject feedback = FeedbackObject.fromJson(f);

            if (feedback.senderId == FirebaseAuthHelper.loggedInUser.uid) {
              project.feedbackArray.remove(f);
              feedback.senderTokens = FirebaseAuthHelper.loggedInUser.fcmTokens;
              project.feedbackArray.add(feedback.toJson());
            }
          }

          await updateProject(project);
        }
      }
    });
  }

  Future<bool> usernameIsAvailable(String username) async {
    bool available;

    await _firestore
        .collection('Users')
        .where('username', isEqualTo: username)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        available = true;
      } else {
        available = false;
      }
    });

    return available;
  }

  Future<bool> emailIsAvailable(String email) async {
    bool available;

    await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        available = true;
      } else {
        available = false;
      }
    });

    return available;
  }

  Future<void> updateProjectsWithNewUserPointsToGive(
      String uid, double newPoints) async {
    await _firestore
        .collection('Projects')
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) async {
      List<ProjectObject> projects = [];

      for (var snap in value.docs) {
        ProjectObject project = ProjectObject.fromJson(snap.data());
        project.userPointsToGive = newPoints;
        projects.add(project);
      }

      for (ProjectObject p in projects) {
        print('Updating ${p.title}');
        await updateProject(p);
      }
    });
  }

  Future<UserObject> getUser(String uid) async {
    UserObject user;

    await _firestore
        .collection('Users')
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) {
      user = UserObject.fromJson(value.docs.first.data());
    });

    return user;
  }

  Future<ProjectObject> getProject(String id) async {
    ProjectObject project;

    await _firestore
        .collection('Projects')
        .where('id', isEqualTo: id)
        .get()
        .then((value) {
      project = ProjectObject.fromJson(value.docs.first.data());
    });

    return project;
  }

  Future<ProjectComplaintObject> getComplaint(String id) async {
    ProjectComplaintObject complaint;

    await _firestore
        .collection('ProjectComplaints')
        .where('id', isEqualTo: id)
        .get()
        .then((value) {
      complaint = ProjectComplaintObject.fromJson(value.docs.first.data());
    });

    return complaint;
  }

  Future<void> updateUser(UserObject user) async {
    await _firestore.collection('Users').doc(user.uid).set(user.toJson());
  }

  Future<void> updateProject(ProjectObject projectObject) async {
    await _firestore
        .collection('Projects')
        .doc(projectObject.id)
        .set(projectObject.toJson());
  }

  Future<void> deleteProject(ProjectObject p) async {
    await _firestore.collection('Projects').doc(p.id).delete();

    List<BlipObject> blips = [];

    for (var b in p.blipArray) {
      blips.add(BlipObject.fromJson(b));
    }

    for (BlipObject b in blips) {
      if (b.imageUrl != null && b.imageUrl != "") {
        StorageReference reference = FirebaseStorage().ref().child(
            "${FirebaseAuthHelper.loggedInUser.uid}/${p.id}/content/${b.id}");

        await reference.delete();
      }
    }

    if (p.thumbnailLink != null && p.thumbnailLink != "") {
      StorageReference ref = FirebaseStorage()
          .ref()
          .child("${FirebaseAuthHelper.loggedInUser.uid}/${p.id}/thumbnail");

      await ref.delete();
    }
  }

  Future<void> submitProjectComplaint(ProjectComplaintObject complaint) async {
    await _firestore
        .collection('ProjectComplaints')
        .doc(complaint.id)
        .set(complaint.toJson());
  }

  Future<void> deleteComplaint(ProjectComplaintObject complaint) async {
    FirebaseAuthHelper.loggedInUser.projectComplaintIdArray
        .remove(complaint.id);

    ProjectObject project = await getProject(complaint.projectId);
    project.flaggedByUid.remove(FirebaseAuthHelper.loggedInUser.uid);

    await _firestore.collection('ProjectComplaints').doc(complaint.id).delete();
    await updateCurrentUser();
    await updateProject(project);
  }
}
