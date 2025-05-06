# frozen_string_literal: true
class ServiceWorkerController < ApplicationController
  protect_from_forgery except: :service_worker

  # This action is used to serve the manifest file
  def manifest
    respond_to do |format|
      format.json do
        render partial: 'pwa/manifest'
      end
    end
  end

  # This action is used to serve the service worker file
  def service_worker
    respond_to do |format|
      format.js do
        render partial: 'pwa/service-worker'
      end
    end
  end


end

