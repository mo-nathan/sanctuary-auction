// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application"
import RankingController from "./ranking_controller"

application.register("ranking", RankingController)
