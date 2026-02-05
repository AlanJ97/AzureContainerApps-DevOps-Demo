{
  "lenses": {
    "0": {
      "order": 0,
      "parts": {
        "0": {
          "position": {
            "x": 0,
            "y": 0,
            "colSpan": 6,
            "rowSpan": 1
          },
          "metadata": {
            "inputs": [],
            "type": "Extension/HubsExtension/PartType/MarkdownPart",
            "settings": {
              "content": {
                "settings": {
                  "content": "# Azure Container Apps - ${project_name}\n## Environment: ${environment_name}\n\nThis dashboard provides real-time monitoring of the Container App deployment including:\n- HTTP request metrics\n- CPU and memory usage\n- Error rates and alerts\n- Application Insights telemetry",
                  "title": "",
                  "subtitle": "",
                  "markdownSource": 1,
                  "markdownUri": null
                }
              }
            }
          }
        },
        "1": {
          "position": {
            "x": 6,
            "y": 0,
            "colSpan": 3,
            "rowSpan": 2
          },
          "metadata": {
            "inputs": [
              {
                "name": "resourceId",
                "value": "${container_app_id}"
              }
            ],
            "type": "Extension/HubsExtension/PartType/ResourcePart",
            "asset": {
              "idInputName": "resourceId",
              "type": "ContainerApp"
            }
          }
        },
        "2": {
          "position": {
            "x": 9,
            "y": 0,
            "colSpan": 3,
            "rowSpan": 2
          },
          "metadata": {
            "inputs": [
              {
                "name": "resourceId",
                "value": "${log_analytics_id}"
              }
            ],
            "type": "Extension/HubsExtension/PartType/ResourcePart",
            "asset": {
              "idInputName": "resourceId",
              "type": "LogAnalytics"
            }
          }
        },
        "3": {
          "position": {
            "x": 0,
            "y": 2,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "isOptional": true
              },
              {
                "name": "sharedTimeRange",
                "isOptional": true
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "content": {
                "options": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": {
                          "id": "${container_app_id}"
                        },
                        "name": "Requests",
                        "aggregationType": 7,
                        "namespace": "microsoft.app/containerapps",
                        "metricVisualization": {
                          "displayName": "Requests"
                        }
                      }
                    ],
                    "title": "HTTP Requests",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": {
                        "isVisible": true,
                        "position": 2,
                        "hideSubtitle": false
                      },
                      "axisVisualization": {
                        "x": {
                          "isVisible": true,
                          "axisType": 2
                        },
                        "y": {
                          "isVisible": true,
                          "axisType": 1
                        }
                      }
                    },
                    "timespan": {
                      "relative": {
                        "duration": 3600000
                      },
                      "showUTCTime": false,
                      "grain": 1
                    }
                  }
                }
              }
            }
          }
        },
        "4": {
          "position": {
            "x": 6,
            "y": 2,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "isOptional": true
              },
              {
                "name": "sharedTimeRange",
                "isOptional": true
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "content": {
                "options": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": {
                          "id": "${container_app_id}"
                        },
                        "name": "UsageNanoCores",
                        "aggregationType": 4,
                        "namespace": "microsoft.app/containerapps",
                        "metricVisualization": {
                          "displayName": "CPU Usage (nanocores)"
                        }
                      }
                    ],
                    "title": "CPU Usage",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": {
                        "isVisible": true,
                        "position": 2,
                        "hideSubtitle": false
                      },
                      "axisVisualization": {
                        "x": {
                          "isVisible": true,
                          "axisType": 2
                        },
                        "y": {
                          "isVisible": true,
                          "axisType": 1
                        }
                      }
                    },
                    "timespan": {
                      "relative": {
                        "duration": 3600000
                      },
                      "showUTCTime": false,
                      "grain": 1
                    }
                  }
                }
              }
            }
          }
        },
        "5": {
          "position": {
            "x": 0,
            "y": 6,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "isOptional": true
              },
              {
                "name": "sharedTimeRange",
                "isOptional": true
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "content": {
                "options": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": {
                          "id": "${container_app_id}"
                        },
                        "name": "WorkingSetBytes",
                        "aggregationType": 4,
                        "namespace": "microsoft.app/containerapps",
                        "metricVisualization": {
                          "displayName": "Memory Working Set (bytes)"
                        }
                      }
                    ],
                    "title": "Memory Usage",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": {
                        "isVisible": true,
                        "position": 2,
                        "hideSubtitle": false
                      },
                      "axisVisualization": {
                        "x": {
                          "isVisible": true,
                          "axisType": 2
                        },
                        "y": {
                          "isVisible": true,
                          "axisType": 1
                        }
                      }
                    },
                    "timespan": {
                      "relative": {
                        "duration": 3600000
                      },
                      "showUTCTime": false,
                      "grain": 1
                    }
                  }
                }
              }
            }
          }
        },
        "6": {
          "position": {
            "x": 6,
            "y": 6,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "isOptional": true
              },
              {
                "name": "sharedTimeRange",
                "isOptional": true
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "content": {
                "options": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": {
                          "id": "${container_app_id}"
                        },
                        "name": "Replicas",
                        "aggregationType": 4,
                        "namespace": "microsoft.app/containerapps",
                        "metricVisualization": {
                          "displayName": "Replica Count"
                        }
                      }
                    ],
                    "title": "Active Replicas",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": {
                        "isVisible": true,
                        "position": 2,
                        "hideSubtitle": false
                      },
                      "axisVisualization": {
                        "x": {
                          "isVisible": true,
                          "axisType": 2
                        },
                        "y": {
                          "isVisible": true,
                          "axisType": 1
                        }
                      }
                    },
                    "timespan": {
                      "relative": {
                        "duration": 3600000
                      },
                      "showUTCTime": false,
                      "grain": 1
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  "metadata": {
    "model": {
      "timeRange": {
        "value": {
          "relative": {
            "duration": 24,
            "timeUnit": 1
          }
        },
        "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
      },
      "filterLocale": {
        "value": "en-us"
      },
      "filters": {
        "value": {
          "MsPortalFx_TimeRange": {
            "model": {
              "format": "utc",
              "granularity": "auto",
              "relative": "24h"
            },
            "displayCache": {
              "name": "UTC Time",
              "value": "Past 24 hours"
            },
            "filteredPartIds": []
          }
        }
      }
    }
  }
}
